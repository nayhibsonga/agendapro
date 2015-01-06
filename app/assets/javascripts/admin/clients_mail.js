function saveBreak (typeURL, extraURL) {

}

var my_alert;
var mails_left;
$(function () {
	my_alert = new Alert();

	mails_left = $('#mails').data('mails-left');

	$('.modal-body div:first').toggle()

	$('input[name="mail"]').change(function (event) {
		var selected = mails_left;
		$('input[name="client_mail"]').each( function () {
			if ($(event.target).prop('checked')) {
				if (selected > 0) {
					$(this).prop('checked', true);
					$('#sendMail').attr('disabled', false);
					selected -= 1;
				};
			}
			else {
				$(this).prop('checked', false);
				$('#sendMail').attr('disabled', true);
			}
		});
	});

	$('input[name="client_mail"]').change(function (event) {
		var selected = mails_left;
		var prop = true;
		var disabled = false;
		$('input[name="client_mail"]').each( function () {
			if ($(this).prop('checked')) {
				if (selected <= 0) {
					$(event.target).prop('checked', false);
					if (selected <= 0) {
						my_alert.showAlert(
							'<h3>Lo sentimos</h3>' +
							'No puedes seleccionar más de ' + mails_left + ' clientes.' +
							'<br>' +
							'Solo puedes mandar un máximo de ' + $('#mails').data('max-mails') + ' e-mails por día.'
						);
					};
				};
				selected -= 1;
			};
			prop = prop && $(this).prop('checked');
			disabled = disabled || $(this).prop('checked');
		});
		$('input[name="mail"]').prop('checked', prop);
		$('#sendMail').attr('disabled', !disabled);
	});

	$('#sendMail').click(function (e) {
		var $link = $(this);
		var emails = [];
		$('input[name="client_mail"]').each( function () {
			if ($(this).prop('checked')) {
				emails.push($(this).val());
			};
		});
		var params = { to: emails };
		var ref = $link.attr('href');
		$link.attr('href', ref + '?' + $.param(params));
	});

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