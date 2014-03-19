$(function() {
	$.validator.setDefaults({
		ignore: ""
	});

	$.validator.addMethod("alphaNumeric", function(value, element) {
		return this.optional(element) || /^\S*[a-z0-9_-]+\S*$/i.test(value); // letters, digits,_,-
	}, "No se pueden usar caractéres especiales");

	$.validator.addMethod('filesize', function(value, element, param) {
		// param = size (en bytes) 
		// element = element to validate (<input>)
		// value = value of the element (file name)
		return this.optional(element) || (element.files[0].size <= param) 
	});

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
		onkeyup: false,
		rules: {
			'company[name]': {
				required: true,
				minlength: 3,
			},
			'company[web_address]': {
				required: true,
				minlength: 3,
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
			'company[name]': {
				required: "Debe ingresar un nombre para la compañia",
				minlength: "El nombre debe tener al menos 3 caracteres",
			},
			'company[web_address]': {
				required: "Debe ingresar una direccion web para su compañia",
				minlength: "La direccion web debe tener al menor 3 caracteres",
				remote: jQuery.validator.format("{0} ya existe")
			},
			'company[logo]': {
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

	$('#company_name').one('change', function() {
		var tmp = $('#company_name').val();
		tmp = tmp.replace(/ /g, '');
		tmp = tmp.toLowerCase();
		$('#company_web_address').val(tmp);
	});
});