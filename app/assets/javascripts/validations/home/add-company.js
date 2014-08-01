$(function() {
	$('#new_company').validate({
		errorPlacement: function(error, element) {
			if (element.attr("id") == 'terms') {
				error.appendTo(element.next().next());
			}
			else if (element.attr('id') == 'company_web_address') {
				error.appendTo(element.parent().next().children('.help-block'));
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'company[name]': {
				required: true,
				minlength: 3,
			},
			'company[web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				alphaNumeric: $('#company_web_address').val(),
				remote: '/check_company'
			},
			'company[logo]': {
				filesize: 3145728
			},
			terms: {
				required: true
			}
		},
		messages: {
			'company[web_address]': {
				remote: jQuery.validator.format("{0} ya existe")
			},
			'company[logo]': {
				filesize: "La imagen supera el tamaño maximo de 3 MB"
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success has-feedback').addClass('has-error has-feedback');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error has-feedback').addClass('has-success has-feedback');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			form.submit();
		}
	});

	$('#company_name').one('change', function() {
		var tmp = $('#company_name').val();
		tmp = tmp.replace(/ /g, '');	//Space
		tmp = tmp.replace(/[áäâà]/gi, 'a');	//special a
		tmp = tmp.replace(/[éëêè]/gi, 'e');	//Special e
		tmp = tmp.replace(/[íïîì]/gi, 'i');	//Special i
		tmp = tmp.replace(/[óöôò]/gi, 'o');	//Special o
		tmp = tmp.replace(/[úüûù]/gi, 'u');	//Special u
		tmp = tmp.replace(/ñ/gi, 'n');	//Special ñ
		tmp = tmp.toLowerCase();
		$('#company_web_address').val(tmp);
	});

});