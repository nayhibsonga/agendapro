$(function() {
	$('#update_configurations_button').click(function(){

		var data = $('.edit_company_setting').serializeArray();

		$.ajax({
			url: '/save_configurations',
			method: 'post',
			dataType: 'json',
			data: data,
			error: function(response){

			},
			success: function(response){

				if(response.status == "ok")
				{
					$('#fieldset_step6').show();
					$('#fieldset_step6').attr('disabled', false);
					scrollToAnchor('fieldset_step6');
				}
				else
				{
					alert("Error");
				}
			}
		});

		
	});
});