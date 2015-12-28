var validator, optimizerValidator;
$(function() {
	validator = $('#new_booking').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (element.attr('id') == 'full_name') {
				error.appendTo(element.parent().next());
			}
			else if (id == 'bookingStartHour' || id == 'bookingStartMinute' || id == 'bookingEndHour' || id == 'bookingEndMinute') {
				// error.appendTo(element.parent().next());
			}
			else{
				error.appendTo(element.next());
			};
		},
		rules: {
			datePicker: {
				required: true
			},
			'booking[start_hours]': {
				require_from_group: [4, '.date-select']
			},
			'booking[start_minutes]': {
				require_from_group: [4, '.date-select']
			},
			'booking[end_hours]': {
				require_from_group: [4, '.date-select']
			},
			'booking[end_minutes]': {
				require_from_group: [4, '.date-select']
			},
			'booking[client][identification_number]': {
				minlength: 2
			},
			'booking[service_provider_id]': {
				required: true
			},
			'booking_staff_code': {
				required: true,
				remote: '/check_staff_code'
			},
			'booking_deal_code': {
				required: $('#calendar-data').data('deal-required')
			},
			'booking[service_id]': {
				required: true
			},
			'booking[price]': {
				required: true,
				number: true,
				min: 0
			},

			full_name: {
				required: true,
				minlength: 3
			}
		},
		messages: {
			'booking[start_hours]': {
				require_from_group: 'Debe elegir una hora.\n'
			},
			'booking[start_minutes]': {
				require_from_group: 'Debe elegir una hora.\n'
			},
			'booking[end_hours]': {
				require_from_group: 'Debe elegir una hora.\n'
			},
			'booking[end_minutes]': {
				require_from_group: 'Debe elegir una hora.\n'
			},
			'booking_staff_code': {
				remote: 'El código es incorrecto, por favor inténtalo nuevamente.'
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
			// form.submit();
		}
	});

	optimizerValidator = $('#hoursOptimizer #new_booking').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (element.attr('id') == 'full_name') {
				error.appendTo(element.parent().next());
			}
			else {
				error.appendTo(element.next());
			};
		},
		rules: {
			'booking_staff_code': {
				required: true,
				remote: '/check_staff_code'
			},
			full_name: {
				required: true,
				minlength: 3
			},
			'booking[client][email]': {
				required: {
					depends: function () {
						var strict_booking = $('#calendar-data').data('strict-booking');
    				var client_phone = $.trim($('#hoursOptimizer #new_booking #booking_client_phone').val());
						return (
							strict_booking && (client_phone == null || client_phone == "")
						);
					}
				},
				email: true
			},
			'booking[client][phone]': {
				required: {
					depends: function () {
						var strict_booking = $('#calendar-data').data('strict-booking');
    				var client_email = $.trim($('#hoursOptimizer #new_booking #booking_client_email').val());
						return (
							strict_booking && (client_email == null || client_email == "")
						);
					}
				},
				rangelength: [7, 15]
			}
		},
		messages: {
			'booking_staff_code': {
				remote: 'El código es incorrecto, por favor inténtalo nuevamente.'
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
			// form.submit();
		}
	});
	$('#booking_client_identification_number').change(function() {
		var id_string = $('#booking_client_identification_number').val()
		$('#booking_client_identification_number').val(identification_number_format(id_string));
	});
});
