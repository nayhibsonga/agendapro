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
	$('#amount_select').change(function(o) {
		$('.md_link').each(function(i, obj) { 
			$(this).attr('href', function(i,a){
				return a.replace( /(amount=)[0-9]+/ig, '$1'+o.target.value );
			});
		});
	});
});