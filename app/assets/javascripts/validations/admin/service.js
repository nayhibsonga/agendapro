$(function() {
	$('form').validate({
		errorPlacement: function(error, element) {
			if (element.attr('id') == 'service_price' || element.attr('id') == 'service_duration' || element.attr('id') == 'service_capacity') {
				error.appendTo(element.parent().next());
			}
			else {
				error.appendTo(element.next());
			};
		},
		rules: {
			'service[name]': {
				required: true,
				minlength: 3
			},
			'service[price]': {
				min: 0
			},
			'service[duration]': {
				required: true,
				min: 0
			},
			'service[capacity]': {
				required: true,
				min: 2
			},
			'service[service_category_id]': {
				required: true
			},
			'service[service_category_attributes][name]': {
				required: true
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