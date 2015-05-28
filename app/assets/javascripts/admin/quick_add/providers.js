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
			service_provider_validation.resetForm();
		    $('#new_service_provider .form-group').removeClass('has-error has-success');
		    $('#new_service_provider .form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check');
	    	$('#next_provider_button').attr('disabled', false);
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
	    	$('#service_provider_'+result.service_provider.id).remove();
	    	if (result.service_provider_count < 1) {
	    		$('#next_provider_button').attr('disabled', true);
	    	}
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
		$('#quick_add_step5').show();
		$('#quick_add_step5').attr('disabled', false);
		scrollToAnchor('quick_add_step5');
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