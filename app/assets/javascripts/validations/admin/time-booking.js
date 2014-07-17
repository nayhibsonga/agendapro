$(function() {
	$('[id^="edit_company_setting_"]').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.parent().next());
		},
		rules: {
			'company_setting[before_booking]': {
				required: true,
				range: [1, 24]
			},
			'company_setting[after_booking]': {
				required: true,
				range: [1, 12]
			},
			'company_setting[before_edit_booking]': {
				required: true,
				range: [1, 24]
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