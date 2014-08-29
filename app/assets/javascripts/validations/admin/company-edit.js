$(function() {
	$('.company-form').validate({
		errorPlacement: function(error, element) {
			if (element.attr('id') == 'company_web_address') {
				error.appendTo(element.parent().parent().next().children('.help-block'));
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'company[name]': {
				required: true,
				minlength: 3,
				maxlength: 200
			},
			'company[web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				alphaNumeric: $('#company_web_address').val()
			},
			'company[logo]': {
				filesize: 3145728
			}
		},
		messages: {
			'company[logo]': {
				filesize: "La imagen supera el tamaño maximo de 3 MB"
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