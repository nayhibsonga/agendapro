$(function() {
	$('#new_user').validate({
		errorPlacement: function(error, element) {
			if (element.attr("id") == 'terms') {
				error.appendTo(element.parent().next());
			}
			else if (element.attr('id') == 'user_company_attributes_web_address') {
				error.appendTo(element.parent().parent().next().children('.help-block'));
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'user[full_name]': {
				required: true
			},
			'user[email]': {
				required: true,
				email: true,
				remote: '/check_user'
			},
			'user[password]': {
				required: true,
				rangelength: [8, 128]
			},
			'user[password_confirmation]': {
				required: true,
				rangelength: [8, 128],
				equalTo: $('input[name="user[password]"]:last')
			},
			'user[company_attributes][name]': {
				required: true,
				minlength: 3,
				maxlength: 200
			},
			'user[company_attributes][web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				alphaNumeric: $('#user_company_attributes_web_address').val(),
				remote: '/check_company'
			},
			terms: {
				required: true
			}
		},
		messages: {
			'user[email]': {
				remote: 'El e-mail ya existe, puedes ingresar o agregar tu compañía <a href="/add_company">aquí</a>.'
			},
			'user[company_attributes][web_address]': {
				remote: 'La dirección web ya existe'
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

	$('#user_company_attributes_name').one('change', function() {
		var tmp = $('#user_company_attributes_name').val();
		tmp = tmp.replace(/ /g, '');		//Space
		tmp = tmp.replace(/\./g, '');		//Dots
		tmp = tmp.replace(/[áäâà]/gi, 'a');	//special a
		tmp = tmp.replace(/[éëêè]/gi, 'e');	//Special e
		tmp = tmp.replace(/[íïîì]/gi, 'i');	//Special i
		tmp = tmp.replace(/[óöôò]/gi, 'o');	//Special o
		tmp = tmp.replace(/[úüûù]/gi, 'u');	//Special u
		tmp = tmp.replace(/ñ/gi, 'n');		//Special ñ
		tmp = tmp.toLowerCase();
		$('#user_company_attributes_web_address').val(tmp);
	});
});