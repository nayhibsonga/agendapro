$(function() {
	$('#client_mailer').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'from': {
				required: true
			},
			'to': {
				required: true
			},
			'subject': {
				required: true,
				minlength: 3
			},
			'message': {
				required: true
			},
			'attachment': {
				filesize: 5242880
			}
		},
		messages: {
			'attachment': {
				filesize: "El archivo supera el tamaño maximo de 5 MB"
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