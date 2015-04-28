function saveServiceProvider () {
	$.ajax({
	    type: 'POST',
	    url: '/quick_add/service_provider.json',
	    data: { "service_provider": { "public_name": $('#service_provider_public_name').val(), "notification_email": $('#service_provider_notification_email').val(), "location_id": $('#service_provider_location_id').val() } },
	    dataType: 'json',
	    success: function (result){
	    	$('#service_providers').append('<tr id="service_provider_'+ result.service_provider.id +'"><td>'+ result.service_provider.public_name +'</td><td>'+ result.service_provider.notification_email +'</td><td>'+ result.location +'</td><td><button id="service_provider_delete_'+ result.service_provider.id +'" class="btn btn-danger btn-xs service-provider-delete-btn"><i class="fa fa-trash-o"></i></button></td></tr>');

	    	$('#service_provider_public_name').val('');
	    	$('#service_provider_notification_email').val('');
	    	$('#service_provider_delete_'+ result.service_provider.id).click(function() {
	    		$('#update_service_provider_spinner').show();
				$('#update_service_provider_button').attr('disabled', true);
	    		deleteServiceProvider(result.service_provider.id);
	    	});
			$('#update_service_provider_button').attr('disabled', false);
			$('#update_service_provider_spinner').hide();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_service_provider_button').attr('disabled', false);
			$('#update_service_provider_spinner').hide();
		}
	});
}

function deleteServiceProvider (id) {
	$.ajax({
	    type: 'DELETE',
	    url: '/quick_add/service_provider/'+ id +'.json',
	    dataType: 'json',
	    success: function (result){
	    	$('#service_provider_'+result.id).remove();
			$('#update_service_provider_button').attr('disabled', false);
			$('#update_service_provider_spinner').hide();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_service_provider_spinner').hide();
		}
	});
}


$(function() {
	$('#next_provider_button').click(function(){
		scrollToAnchor('quick_add_step5');
	});

	$('#update_service_provider_button').click(function() {
		$('#update_service_provider_spinner').show();
		$('#update_service_provider_button').attr('disabled', true);
		saveServiceProvider();
	});

	$('.service-provider-delete-btn').click(function(event) {
		$('#update_service_provider_spinner').show();
		$('#update_service_provider_button').attr('disabled', true);
		window.console.log(event);
		if (parseInt(event.currentTarget.id.split("service_provider_delete_")[1]) > 0) {
			deleteServiceProvider(parseInt(event.currentTarget.id.split("service_provider_delete_")[1]));
		}
		else {
			window.console.log("Bad provider delete");
		}
	});

});