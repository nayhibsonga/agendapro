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
					$('#sendMail').prop('disabled', false);
					selected -= 1;
				};
			}
			else {
				$(this).prop('checked', false);
				$('#sendMail').prop('disabled', true);
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
							'No puede seleccionar más de ' + mails_left + ' clientes.' +
							'<br>' +
							'Solo puede mandar un máximo de ' + $('#mails').data('max-mails') + ' emails por día.'
						);
					};
				};
				selected -= 1;
			};
			prop = prop && $(this).prop('checked');
			disabled = disabled || $(this).prop('checked');
		});
		$('input[name="mail"]').prop('checked', prop);
		$('#sendMail').prop('disabled', !disabled);
	});

	$('#mailModal').on('show.bs.modal', function (e) {
		var emails = [];
		$('input[name="client_mail"]').each( function () {
			if ($(this).prop('checked')) {
				emails.push($(this).val());
			};
		});
		$('#to').val(emails);
	});

	$.validator.addMethod('filesize', function(value, element, param) {
		// param = size (en bytes) 
		// element = element to validate (<input>)
		// value = value of the element (file name)
		return this.optional(element) || (element.files[0].size <= param) 
	});
	
	$('#client_mailer').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'to': {
				required: true
			},
			'subject': {
				required: true
			},
			'message': {
				required: true
			},
			'attachment': {
				filesize: 3145728
			}
		},
		messages: {
			'to': {
				required: "Debe elegir al menos un destinatario"
			},
			'subject': {
				required: "Debe escribir un asunto para su e-mail"
			},
			'message': {
				required: "No se puede dejar el cuerpo vacío"
			},
			'attachment': {
				filesize: "El archivo supera el tamaño maximo de 3 MB"
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			form.submit();
		}
	});

	$('#send_mail_button').click( function () {
		if($('#client_mailer').valid()) {
			$('.form-group').toggle();
			$('.modal-footer .btn').toggle();
			$('.modal-body div:first').toggle()
		}
	});

	$('#location').change( function () {
		var localId = $('#location').val();
		if ($('#location').val() > 0) {
			$.getJSON('/local_providers', {location: localId }, function (providersArray) {
				$('#provider').empty();
				$('#provider').append('<option value="">Elige un Proveedor...</option>');
				$.each(providersArray, function (key, provider) { 
					$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
				});
			});
		}
		else {
			$.getJSON('/service_providers.json', function (providersArray) {
				$('#provider').empty();
				$('#provider').append('<option value="">Elige un Proveedor...</option>');
				$.each(providersArray, function (key, provider) { 
					$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
				});
			});
		}
	});
});