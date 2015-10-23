var location_validation;
var service_category_validation;
var service_validation;
var service_provider_validation;

$(function() {
	location_validation = $('#new_location').submit(function(e) {
		e.preventDefault();
		window.console.log('prevented');
	}).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'location[name]': {
				required: true,
				minlength: 3
			},
			'country': {
				required: true
			},
			'region': {
				required: true
			},
			'city': {
				required: true
			},
			'location[district_id]': {
				required: true
			},
			'location[address]': {
				required: true,
				minlength: 3
			},
			'location[phone]': {
				required: true,
				minlength: 8,
				maxlength: 12
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
			$('#update_location_spinner').show();
			$('#update_location_button').attr('disabled', true);
			$('#next_location_button').attr('disabled', true);
			if($(form).find('button').first().attr('name') == 'new_location_btn') {
				saveLocation('POST','');
			}
			else {
				if (parseInt($(form).find('button').first().attr('name').split("edit_location_btn_")[1]) > 0) {
					saveLocation('PATCH', '/'+parseInt($(form).find('button').first().attr('name').split("edit_location_btn_")[1]));
				}
				else {
					window.console.log("Bad location update");
				}
			}

		}
	});

	service_category_validation = $('#new_service_category').submit(function(e) {
		e.preventDefault();
	}).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'service_category[name]': {
				required: true,
				minlength: 3
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
			$('#update_service_category_spinner').show();
			$('#update_service_category_button').attr('disabled', true);
			saveServiceCategory();
		}
	});

	service_validation = $('#new_service').submit(function(e) {
		e.preventDefault();
	}).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'service[name]': {
				required: true,
				minlength: 3
			},
			'service[price]': {
				required: true,
				min: 0
			},
			'service[duration]': {
				required: true
			},
			'service[service_category_id]': {
				required: true
			},
			'service[sessions_amount]': {
				required: true
			},
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
			$('#update_service_spinner').show();
			$('#update_service_button').attr('disabled', true);
			saveService();
		}
	});

	service_provider_validation = $('#new_service_provider').submit(function(e) {
		e.preventDefault();
	}).validate({
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
				email: true,
				minlength: 3
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
			$('#update_service_provider_spinner').show();
			$('#update_service_provider_button').attr('disabled', true);
			saveServiceProvider();		}
	});

	$('[id^="edit_company_"]').submit(function(e) {
		e.preventDefault();
	}).validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
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
