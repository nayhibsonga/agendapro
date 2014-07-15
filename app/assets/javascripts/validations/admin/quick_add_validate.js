$(function() {
	$.validator.setDefaults({
		ignore: ""
	});

	$('#new_location').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'location[name]': {
				required: true,
				minlength: 3
			},
			'location[address]': {
				required: true,
				minlength: 3
			},
			'location[phone]': {
				required: true,
				minlength: 8,
				maxlength: 12
			},
			'location[district_id]': {
				required: true
			}
		},
		messages: {
			'location[name]': {
				required: 'Debe ingresar un nombre para el Local',
				minlength: 'Debe tener al menos 3 caractéres'
			},
			'location[address]': {
				required: 'Debe ingresar una dirección para el Local',
				minlength: 'Debe tener al menos 3 caractéres'
			},
			'location[phone]': {
				required: 'Debe ingresar un teléfono',
				minlength: 'Debe tener al menos 8 digitos',
				maxlength: 'No puede ser mas largo de 12 caractéres'
			},
			'location[district_id]': {
				required: 'Debe seleccionar una comuna'
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

	$('#new_service').validate({
		errorPlacement: function(error, element) {
			if (element.attr('id') == 'service_price') {
				error.appendTo(element.parent().next());
			}
			else if (element.attr('id') == 'service_duration') {
				error.appendTo(element.parent().next());
			}
			else if (element.attr('id') == 'service_capacity') {
				error.appendTo(element.parent().next());
			}
			else {
				error.appendTo(element.next());
			}
			$('#foo5').trigger('updateSizes');
		},
		rules: {
			'service[name]': {
				required: true,
				minlength: 3
			},
			'service[price]': {
				required: true,
				min: 0,
				digits: true
			},
			'service[duration]': {
				required: true,
				min: 5,
				max: 1439,
				digits: true
			},
			'service[service_category_id]': {
				required: true
			},
			'service[service_category_attributes][name]': {
				required: true,
				minlength: 3
			},
			'service[capacity]': {
				required: true,
				min: 2,
				digits: true
			}
		},
		messages: {
			'service[name]': {
				required: 'Debe ingresar un nombre para el Servicio',
				minlength: 'Debe ingresar al menos 3 caractéres'
			},
			'service[price]': {
				required: 'Debe ingresar un precio',
				min: 'El valor del servicio no puede ser menor a $1',
				digits: 'El valor tiene que ser númerico'
			},
			'service[duration]': {
				required: 'Debe ingresar una duración',
				min: 'El servicio no puede durar menos de 5 minutos',
				max: 'El servicio no puede durar mas de 24 horas',
				digits: 'El tiempo tiene que ser un valor númerico'
			},
			'service[service_category_id]': {
				required: 'Debe seleccionar una categoria'
			},
			'service[service_category_attributes][name]': {
				required: 'Debe escribir una categoria',
				minlength: 'Debe ingresar al menos 3 caractéres'
			},
			'service[capacity]': {
				required: 'Debe ingresar una capacidad',
				min: 'El servicio debe permitir al menos 2 personas',
				digits: 'La cantidad tiene que ser un valor númerico'
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

	$('#new_service_provider').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'service_provider[public_name]': {
				required: true,
				minlength: 3
			},
			'service_provider[notification_email]': {
				required: true,
				minlength: 3,
				email: true
			}
		},
		messages: {
			'service_provider[public_name]': {
				required: 'Debe ingresar un nombre para el Staff',
				minlength: 'Debe ingresar al menos 3 caractéres'
			},
			'service_provider[notification_email]': {
				required: 'Debe ingresar un email para notificar al Staff',
				minlength: 'Debe ingresar al menos 3 caractéres',
				email: 'Debe ingresar un email valido'
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