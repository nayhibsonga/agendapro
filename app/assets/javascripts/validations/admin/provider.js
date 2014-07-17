$(function() {
	$('form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'service_provider[public_name]': {
				required: true,
				minlength: 3
			},
			'service_provider[notification_email]': {
				required: true,
				email: true
			},
			'service_provider[location_id]': {
				required: true
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
		}//,
		// submitHandler: function(form) {
		// 	form.submit();
		// }
	});
});