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

	$('form').validate({
		errorPlacement: function(error, element) {
			if (element.attr('id') == 'company_web_address') {
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
				maxlength: 200
			},
			'company[web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				alphaNumeric: $('#company_web_address').val()//,
				//remote: '/check_company'
			},
			'company[logo]': {
				filesize: 3145728
			}
		},
		messages: {
			'company[name]': {
				required: "Debe ingresar un nombre para la compañia",
				minlength: "El nombre debe tener al menos 3 caractéres",
				maxlength: "El nombre no puede ser más largo de 200 caractéres"
			},
			'company[web_address]': {
				required: "Debe ingresar una direccion web para su compañia",
				minlength: "La direccion web debe tener al menor 3 caractéres",
				maxlength: "La direccion no puede ser más larga de 200 caractéres"//,
				//remote: jQuery.validator.format('{0} ya existe')
			},
			'company[logo]': {
				filesize: "La imagen supera el tamaño maximo de 3 MB"
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			form.submit();
		}
	});
});