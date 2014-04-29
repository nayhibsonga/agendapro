$(function() {
	$.validator.setDefaults({
		ignore: ""
	});

	$.validator.addMethod("alphaNumeric", function(value, element) {
		return this.optional(element) || /^\S*[a-z0-9_-]+\S*$/i.test(value) && !value.match(/[áäâàéëêèíïîìóöôòúüûùñ.]/gi); // letters, digits,_,-
	}, "No se pueden usar caractéres especiales");

	$.validator.addMethod('filesize', function(value, element, param) {
		// param = size (en bytes) 
		// element = element to validate (<input>)
		// value = value of the element (file name)
		return this.optional(element) || (element.files[0].size <= param) 
	});

	$('#new_user').validate({
		errorPlacement: function(error, element) {
			if (element.attr("id") == 'terms') {
				error.appendTo(element.next().next());
			}
			else if (element.attr('id') == 'user_company_attributes_web_address') {
				error.appendTo(element.parent().next().children('.help-block'));
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'user[first_name]': {
				required: true,
				minlength: 3
			},
			'user[last_name]': {
				required: true,
				minlength: 3
			},
			'user[phone]': {
				required: true,
				rangelength: [7, 12]
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
				equalTo: "#user_password"
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
			'user[company_attributes][logo]': {
				filesize: 3145728
			},
			terms: {
				required: true
			}
		},
		messages: {
			'user[first_name]': {
				required: "Es requerido un nombre de usuario",
				minlength: "El nombre debe tener al menos 3 caract&eacute;res"
			},
			'user[last_name]': {
				required: "Es requerido su apellido",
				minlength: "El apellido debe tener al menos 3 caract&eacute;res"
			},
			'user[phone]': {
				required: "Es necesario ingresar un tel&eacute;fono",
				rangelength: "El largo del teléfono debe estar en el rango de 7 a 12 numeros"
			},
			'user[email]': {
				required: "Por favor ingrese un email v&aacute;lido",
				email: "Por favor ingrese un email v&aacute;lido",
				remote: jQuery.validator.format('{0} ya existe, puedes ingresar o agregar tu compañía <a href="/add_company">aquí</a>.')
			},
			'user[password]': {
				required: "Debe ingresar una contraseña",
				rangelength: "La contraseña debe tener un largo entre 8 y 128 caracteres"
			},
			'user[password_confirmation]': {
				required: "Debe ingresar una contraseña",
				rangelength: "La contraseña debe tener un largo entre 8 y 128 caracteres",
				equalTo: "La contraseña no coincide"
			},
			'user[company_attributes][name]': {
				required: "Debe ingresar un nombre para la compañia",
				minlength: "El nombre debe tener al menos 3 caractéres",
				maxlength: "El nombre no puede ser más largo de 200 caractéres"
			},
			'user[company_attributes][web_address]': {
				required: "Debe ingresar una direccion web para su compañia",
				minlength: "La direccion web debe tener al menor 3 caractéres",
				maxlength: "La direccion no puede ser más larga de 200 caractéres",
				remote: jQuery.validator.format('{0} ya existe')
			},
			'user[company_attributes][logo]': {
				filesize: "La imagen supera el tamaño maximo de 3 MB"
			},
			terms: {
				required: "Debe aceptar los terminos y condiciones"
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

	$('#user_company_attributes_name').one('change', function() {
		var tmp = $('#user_company_attributes_name').val();
		tmp = tmp.replace(/ /g, '');	//Space
		tmp = tmp.replace(/\./g, '');	//Dots
		tmp = tmp.replace(/[áäâà]/gi, 'a');	//special a
		tmp = tmp.replace(/[éëêè]/gi, 'e');	//Special e
		tmp = tmp.replace(/[íïîì]/gi, 'i');	//Special i
		tmp = tmp.replace(/[óöôò]/gi, 'o');	//Special o
		tmp = tmp.replace(/[úüûù]/gi, 'u');	//Special u
		tmp = tmp.replace(/ñ/gi, 'n');	//Special ñ
		tmp = tmp.toLowerCase();
		$('#user_company_attributes_web_address').val(tmp);
	});
});