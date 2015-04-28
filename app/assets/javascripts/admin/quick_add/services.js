// $('input').on('itemAdded', function(event) {
//   // event.item: contains the item
// });
// $('input').on('beforeItemRemove', function(event) {
//   // event.item: contains the item
//   // event.cancel: set to true to prevent the item getting removed
// });

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
			$('#update_service_category_button').attr('disabled', false);
			$('#update_service_category_spinner').hide();
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
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_service_category_spinner').hide();
		}
	});
}

function saveService () {
	$.ajax({
	    type: 'POST',
	    url: '/quick_add/service.json',
	    data: { "service": { "name": $('#service_name').val(), "price": $('#service_price').val(), "duration": $('#service_duration').val(), "service_category_id": $('#service_service_category_id').val() } },
	    dataType: 'json',
	    success: function (result){
	    	$('#services').append('<tr id="service_'+ result.service.id +'"><td>'+ result.service.name +'</td><td>$ '+ result.service.price.toFixed(0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".") +'</td><td>'+ result.service.duration +' min.</td><td>'+ result.service_category +'</td><td><button id="service_delete_'+ result.service.id +'" class="btn btn-danger btn-xs service-delete-btn"><i class="fa fa-trash-o"></i></button></td></tr>');

	    	$('#service_name').val('');
	    	$('#service_price').val('');
	    	$('#service_duration').val('');
	    	$('#service_delete_'+ result.service.id).click(function() {
	    		$('#update_service_spinner').show();
				$('#update_service_button').attr('disabled', true);
	    		deleteService(result.service.id);
	    	});
			$('#update_service_button').attr('disabled', false);
			$('#update_service_spinner').hide();
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
	    	$('#service_'+result.id).remove();
			$('#update_service_button').attr('disabled', false);
			$('#update_service_spinner').hide();
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
			$('#update_service_spinner').hide();
		}
	});
}


$(function() {
	$('#next_service_button').click(function(){
		scrollToAnchor('fieldset_step4');
	});

	$('#update_service_category_button').click(function() {
		$('#update_service_category_spinner').show();
		$('#update_service_category_button').attr('disabled', true);
		saveServiceCategory();
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

	$('#update_service_button').click(function() {
		$('#update_service_spinner').show();
		$('#update_service_button').attr('disabled', true);
		saveService();
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

});