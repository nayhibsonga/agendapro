var my_alert;
var monthly_mails;
var monthly_mails_sent;
$(function () {
	my_alert = new Alert();

	monthly_mails = $('#mails').data('monthly-mails');
	monthly_mails_sent = $('#mails').data('monthly-mails-sent');

	$('.modal-body div:first').toggle()

	// $('input[name="mail"]').change(function (event) {
	// 	var mails_sent = monthly_mails_sent;
	// 	$('input[name="client_mail"]').each( function () {
	// 		if ($(event.target).prop('checked')) {
	// 			if (mails_sent < monthly_mails) {
	// 				$(this).prop('checked', true);
	// 				mails_sent += 1;
	// 			};
	// 		}
	// 		else {
	// 			$(this).prop('checked', false);
	// 		}
	// 	});
	// });

	// $('input[name="client_mail"]').change(function (event) {
	// 	var mails_sent = monthly_mails_sent;
	// 	$('input[name="client_mail"]').each( function () {
	// 		if ($(this).prop('checked')) {
	// 			mails_sent += 1;
	// 			if (mails_sent > monthly_mails) {
	// 				$(event.target).prop('checked', false);
	// 			};
	// 		};
	// 	});
	// 	if (mails_sent > monthly_mails) {
	// 		my_alert.showAlert(
	// 			'<h3>Lo sentimos</h3>' +
	// 			'No puedes seleccionar más de ' + (monthly_mails - monthly_mails_sent) + ' clientes.' +
	// 			'<br>' +
	// 			'Solo puedes mandar un máximo de ' + monthly_mails + ' e-mails al mes.'
	// 		);
	// 	};
	// });

	// $('#sendMail').click(function (e) {
	// 	var $link = $(this);
	// 	var emails = [];
	// 	if ($('input[name="mail"]').prop('checked')) {
	// 		emails = $('input[name="mail"]').data('mails');
	// 	} else{
	// 		$('input[name="client_mail"]').each( function () {
	// 			if ($(this).prop('checked')) {
	// 				emails.push($(this).val());
	// 			};
	// 		});
	// 	};
	// 	var params = { to: emails };
	// 	var ref = $link.attr('href');
	// 	$link.attr('href', ref + '?' + $.param(params));
	// });

	$('#location').change( function () {
		var localId = $('#location').val();
		if ($('#location').val() > 0) {
			$.getJSON('/local_providers', {location: localId }, function (providersArray) {
				$('#provider').empty();
				$('#provider').append('<option value="">Elige un Prestador...</option>');
				$.each(providersArray, function (key, provider) {
					$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
				});
			});
		}
		else {
			$.getJSON('/service_providers.json', function (providersArray) {
				$('#provider').empty();
				$('#provider').append('<option value="">Elige un Prestador...</option>');
				$.each(providersArray, function (key, provider) {
					$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
				});
			});
		}
	});
	$('#file').change( function () {
		if ($('#file').val()) {
			$('#import_button').removeAttr("disabled");
		}
		else {
			$('#import_button').attr("disabled", "disabled");
		}
	});
	$('#file-group').show();
	$('.client_can_book').change(function(event) {
		$('#client_can_book'+event.target.value).hide();
		$('#loader'+event.target.value).show();
		$.ajax({
			type: 'PATCH',
			url: '/clients/'+event.target.value+'.json',
			data: { "client": { "can_book": $('#client_can_book'+event.target.value).prop('checked') } },
			dataType: 'json',
			success: function(provider_break){
				$('#loader'+event.target.value).hide();
				$('#client_can_book'+event.target.value).show();
			},
			error: function(xhr){
				$('#loader'+event.target.value).hide();
				$('#client_can_book'+event.target.value).prop('checked', !$('#client_can_book'+event.target.value).prop('checked'));
				$(event.target.id).show();
				var errors = $.parseJSON(xhr.responseText).errors;
				var errores = 'Error\n';
				for (i in errors) {
					errores += '*' + errors[i] + '\n';
				}
				alert(errores);
				// alertId.showAlert(errores);
			}
		});
	});
});
