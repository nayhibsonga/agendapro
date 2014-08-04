var validator;
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
			'booking[service_provider_id]': {
				required: true
			},
			'booking[service_id]': {
				required: true
			},
			'booking[price]': {
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
});