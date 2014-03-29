$(function() {
	$('#signup-form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
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
				equalTo: $('input[name="user[password]"]:last')
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
				remote: jQuery.validator.format('{0} ya existe, puedes crear tu compañia <a href="/add_company">aquí</a>.')
			},
			'user[password]': {
				required: "Debe ingresar una contraseña",
				rangelength: "La contraseña debe tener un largo entre 8 y 128 caracteres"
			},
			'user[password_confirmation]': {
				required: "Debe ingresar una contraseña",
				rangelength: "La contraseña debe tener un largo entre 8 y 128 caracteres",
				equalTo: "La contraseña no coincide"
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
});
