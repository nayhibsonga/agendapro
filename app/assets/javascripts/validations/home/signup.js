$(function() {
	$('#signup-form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'user[full_name]': {
				required: true
			},
			// 'user[phone]': {
			// 	required: true,
			// 	rangelength: [8, 15]
			// },
			'user[email]': {
				required: true,
				email: true,
				remote: '/check_user'
			}
		},
		messages: {
			'user[email]': {
				remote: 'El e-mail ya existe, puedes crear tu compañia <a href="/add_company">aquí</a>.'
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
			form.submit();
		}
	});

	$("#signup-form #user_password").rules("add", {required: true, rangelength: [8, 128]});
	$("#signup-form #user_password_confirmation").rules("add", {required: true, rangelength: [8, 128], equalTo: $('#signup-form #user_password')});

});