var validator;
$(function() {
	validator = $('form').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (element.attr('id') == 'name') {
				error.appendTo(element.parent().next());
			}
			else {
				error.appendTo(element.next());
			};
		},
		rules: {
			'date': {
				required: true
			},
			'booking[service_provider]': {
				required: true
			},
			'booking_staff_code': {
				required: true,
				remote: '/check_staff_code'
			},
			'booking[service]': {
				required: true
			},
			'booking[price]': {
				min: 0
			},
			'name': {
				required: true,
				minlength: 3
			}
		},
		messages: {
			'booking_staff_code': {
				remote: 'El código es incorrecto, por favor inténtalo nuevamente.'
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			// form.submit();
		}
	});
});
