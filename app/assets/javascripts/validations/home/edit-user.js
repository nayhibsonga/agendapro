$(function() {
	$('#edit_user').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'user[full_name]': {
				required: true
			},
			'user[phone]': {
				required: true,
				rangelength: [8, 15]
			},
			'user[email]': {
				required: true,
				email: true
			},
			'user[password]': {
				rangelength: [8, 128]
			},
			'user[password_confirmation]': {
				rangelength: [8, 128],
				equalTo: $('input[name="user[password]"]:last')
			},
			'user[current_password]': {
				required: true,
				rangelength: [8, 128]
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
});