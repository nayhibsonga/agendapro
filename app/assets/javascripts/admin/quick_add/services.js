function saveServiceCategory () {
	$.ajax({
	    type: 'POST',
	    url: '/quick_add/service_category.json',
	    data: { "service_category": { "name": $('#service_category_name').val() } },
	    dataType: 'json',
	    success: function (result){
	    	$('#service_categories').append('<div id="service_category_'+ result.id +'" class="category-pill">'+ result.name +' <button id="service_category_delete_'+ result.id +'" class="btn btn-default btn-xs service-category-delete-btn"><i class="fa fa-times"></i></button></div>');
	    	$('#service_service_category_id').append('<option value="'+ result.id +'">'+ result.name +'</option>');
	    	$('#service_category_name').val('');
	    	$('#service_category_delete_'+ result.id).click(function() {
	    		$('#update_service_category_spinner').show();
				$('#update_service_category_button').attr('disabled', true);
	    		deleteServiceCategory(result.id);
	    	});
			service_category_validation.resetForm();
		    $('#new_service_category .form-group').removeClass('has-error has-success');
		    $('#new_service_category .form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check');
			$('#update_service_category_button').attr('disabled', false);
			$('#update_service_category_spinner').hide();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n<ul>" + errorList + "</ul>",
        type: "error",
        html: true
      });
			$('#update_service_category_button').attr('disabled', false);
			$('#update_service_category_spinner').hide();
		}
	});
}

function deleteServiceCategory (id) {
	$.ajax({
	    type: 'DELETE',
	    url: '/quick_add/service_category/'+ id +'.json',
	    dataType: 'json',
	    success: function (result){
	    	$('#service_category_'+result.id).remove();
	    	$('#service_service_category_id option[value="'+ result.id +'"]').remove();
			$('#update_service_category_button').attr('disabled', false);
			$('#update_service_category_spinner').hide();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n<ul>" + errorList + "</ul>",
        type: "error",
        html: true
      });
			$('#update_service_category_spinner').hide();
		}
	});
}

function saveService () {
	$.ajax({
	    type: 'POST',
	    url: '/quick_add/service.json',
	    data: {
	    	"service": {
	    		"name": $('#service_name').val(),
	    		"price": $('#service_price').val(),
	    		"duration": $('#service_duration').val(),
	    		"service_category_id": $('#service_service_category_id').val(),
	    		"has_sessions": $('#service_has_sessions').is(':checked'),
	    		"sessions_amount": $('#service_sessions_amount').val(),
	    		"description": $('#service_description').val()
	    	}
	    },
	    dataType: 'json',
	    success: function (result){
	    	$('#services').append('<tr id="service_'+ result.service.id +'"><td>'+ result.service.name +'</td><td>$ '+ result.service.price.toFixed(0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") +'</td><td>'+ result.service.duration +' min.</td><td>'+ result.service_category +'</td><td>' + result.service.description + '</td><td><button id="service_delete_'+ result.service.id +'" class="btn btn-danger btn-xs service-delete-btn"><i class="fa fa-trash-o"></i></button></td></tr>');

	    	$('#service_name').val('');
	    	$('#service_price').val('');
	    	$('#service_duration').val('');
	    	$('#service_sessions_amount').val('');
	    	if ($('#service_has_sessions').is(':checked')) {
	    		$('#service_has_sessions').click();
	    	};
	    	$('#service_delete_'+ result.service.id).click(function() {
	    		$('#update_service_spinner').show();
					$('#update_service_button').attr('disabled', true);
	    		deleteService(result.service.id);
	    	});
			service_validation.resetForm();
		    $('#new_service .form-group').removeClass('has-error has-success has-feedback');
		    $('#new_service .form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check');
	    	$('#next_service_button').attr('disabled', false);
			$('#update_service_button').attr('disabled', false);
			$('#update_service_spinner').hide();
		},
		error: function (xhr){
		  var errors = $.parseJSON(xhr.responseText).errors;
		  var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n<ul>" + errorList + "</ul>",
        type: "error",
        html: true
      });
			$('#update_service_button').attr('disabled', false);
			$('#update_service_spinner').hide();
		}
	});
}

function deleteService (id) {
	$.ajax({
	    type: 'DELETE',
	    url: '/quick_add/service/'+ id +'.json',
	    dataType: 'json',
	    success: function (result){
	    	$('#service_'+result.service.id).remove();
	    	if (result.service_count < 1) {
	    		$('#next_service_button').attr('disabled', true);
	    	}
			$('#update_service_button').attr('disabled', false);
			$('#update_service_spinner').hide();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n<ul>" + errorList + "</ul>",
        type: "error",
        html: true
      });
			$('#update_service_spinner').hide();
		}
	});
}


$(function() {
	$('#next_service_button').click(function(){
		$('#fieldset_step4').show();
		$('#fieldset_step4').attr('disabled', false);
		scrollToAnchor('fieldset_step4');
	});

	$('.service-category-delete-btn').click(function(event) {
		$('#update_service_category_spinner').show();
		$('#update_service_category_button').attr('disabled', true);
		window.console.log(event);
		if (parseInt(event.currentTarget.id.split("service_category_delete_")[1]) > 0) {
			deleteServiceCategory(parseInt(event.currentTarget.id.split("service_category_delete_")[1]));
		}
		else {
			window.console.log("Bad category delete");
		}
	});

	$('.service-delete-btn').click(function(event) {
		$('#update_service_spinner').show();
		$('#update_service_button').attr('disabled', true);
		window.console.log(event);
		if (parseInt(event.currentTarget.id.split("service_delete_")[1]) > 0) {
			deleteService(parseInt(event.currentTarget.id.split("service_delete_")[1]));
		}
		else {
			window.console.log("Bad service delete");
		}
	});

	$('#service_has_sessions').click(function (e) {
			if($("#service_has_sessions").is(':checked')){
				$('#service_sessions_amount').closest('.form-group').removeClass('hidden');
				$('#service_sessions_amount').attr('disabled', false);
			}
			else{
				$('#service_sessions_amount').closest('.form-group').addClass('hidden');
				$('#service_sessions_amount').attr('disabled', true);
			}
	});

});
