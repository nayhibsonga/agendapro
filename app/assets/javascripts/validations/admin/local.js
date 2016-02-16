$(function() {
	$('#new_location, [id^="edit_location_"]').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (id == "address") {
				error.appendTo(element.parent().next());
			} else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'location[company_id]': {
				required: true
			},
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
			'address': {
				required: true
			},
			'location[phone]': {
				required: true,
				rangelength: [8, 15]
			},
			'location[email]': {
				email: true
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

	$('input[name="location[notification]"]').change(function (event) {
		var value = $(event.target).prop('checked')
		if (value) {
			$('input[name="location[email]"]').rules('add', {
				required: true
			});
		} else{
			$('input[name="location[email]"]').rules('remove', 'required');
			$('input[name="location[email]"]').closest('.form-group').removeClass('has-error').removeClass('has-success');
			$('input[name="location[email]"]').parent().children('.form-control-feedback').removeClass('fa fa-times').removeClass('fa fa-check');
			$('input[name="location[email]"]').next().empty()
		};
	});

});
