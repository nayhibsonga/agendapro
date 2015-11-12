$(function() {
	$('#next_provider_button').click(function(){
		$('#quick_add_step6').show();
		$('#quick_add_step6').attr('disabled', false);
		scrollToAnchor('quick_add_step6');
	});
});