$(function() {
	$('form').validate({
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
				required: true
			},
			'location[phone]': {
				required: true,
				rangelength: [8, 15]
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
		}//,
		// submitHandler: function(form) {
		// 	form.submit();
		// }
	});
});