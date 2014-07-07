$(function() {
	if (!$('#billing_info_active').prop('checked')) {
		$('input.form-control').attr('disabled', true);
	}
	else {
		$('input.form-control').attr('disabled', false);
	}
	$('#billing_info_active').change(function() {
		if (!$('#billing_info_active').prop('checked')) {
			$('input.form-control').attr('disabled', true);
		}
		else {
			$('input.form-control').attr('disabled', false);
		}
	});
});