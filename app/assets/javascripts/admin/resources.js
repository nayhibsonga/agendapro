function changeLocationStatus(location_id) {
	if( $('#resource_location_ids_'+location_id).prop('checked')) {
		$('#resource_location_ids_quantity_'+location_id).prop('disabled', false);
	}
	else {
		$('#resource_location_ids_quantity_'+location_id).prop('disabled', true);
		$('#resource_location_ids_quantity_'+location_id).val('');
	}
}

function saveCategory (typeURL, extraURL) {
	$('#saveResourceCategryButton').attr('disabled', true);
	var categoryJSON = { "name": $('#resource_category_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("Estás seguro?");
		if (r != true) {
		    return false;
		}
	}
	else if (!$('#new_resource_category').valid()) {
		return false;
	};
	$.ajax({
		type: typeURL,
		url: '/resource_categories'+extraURL+'.json',
		data: { "resource_category": categoryJSON },
		dataType: 'json',
		success: function(resource_category){
			switch(typeURL) {
			case 'POST':
				$('#resource_resource_category_id').append('<option value="'+resource_category.id+'">'+resource_category.name+'</option>');
				$('#resource_resource_category_id option[value="'+resource_category.id+'"]').prop('selected', true);
				$('#resourceCategoryModal').modal('hide');
				$('#saveResourceCategryButton').attr('disabled', false);
				break;
			case 'PATCH':
				$('#saveResourceCategryButton').attr('disabled', false);
				break;
			case 'DELETE':
				$('#resource_resource_category_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#resourceCategoryModal').modal('hide');
				$('#saveResourceCategryButton').attr('disabled', false);
				break;
			}
		},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errores = 'Error\n';
			for (i in errors) {
				errores += '*' + errors[i] + '\n';
			}
			alert(errores);
			$('#saveResourceCategryButton').attr('disabled', false);
		}
	});
}

function saveResource (typeURL, extraURL) {
	if (!$(form).valid()) {
		return false;
	};
	$.each($('input[name="resource[location_ids_quantity][]"]'), function (key, resource) {
		if (!$(resource).attr('disabled')) {
			$(resource).valid();
		};
	});
	if (validator_resource.numberOfInvalids()) {
		return false;
	};
	var resource_services = []
	$('input.resourceServiceCheck').each(function() {
		if ($(this).prop('checked')) {
	    	resource_services.push($(this).val());
		}
	});
	var resource_locations = []
	$('input.resourceLocationCheck').each(function() {
		if ($('#resource_location_ids_'+$(this).val()).prop('checked')) {
	    	resource_locations.push({ "location_id": $(this).val(), "quantity": $('#resource_location_ids_quantity_'+$(this).val()).val() });
		}
	});
	var resourceJSON = { "name": $('#resource_name').val(), "resource_category_id": $('#resource_resource_category_id').val(), "service_ids": resource_services, "resource_locations_attributes": resource_locations };
	$.ajax({
		type: typeURL,
		url: '/resources'+extraURL+'.json',
		data: { "resource": resourceJSON },
		dataType: 'json',
		success: function() {
			document.location.href = '/resources/';
		},
		error: function(xhr){
			var errores = $.parseJSON(xhr.responseText).errors;
			var errorList = '';
			for (i in errores) {
				errorList += '<li>' + errores[i] + '</li>'
			}
			alertId.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
		}
	});
}

function getResourceCategories() {
	$('#resource_category_name').val('');
	$('#resourceCategoriesTable').empty();
	$.getJSON('/resource_categories', function (categoriesArray) {
		$.each(categoriesArray, function (key, category) {
			var buttonString = '';
			if(category.name != "Otros") {
				buttonString = '<a class="btn btn-red" onclick="saveCategory(\'DELETE\',\'/'+category.id+'\')"><i class="fa fa-trash-o"></i></a>';
			}
			$('#resourceCategoriesTable').append('<tr><td>'+category.name+'</td><td>'+buttonString+'</td></tr>');
		});
		$('#resourceCategoryModal').modal('show');
	});
}
var form;
function initialize() {
	if ($("#id_data").length > 0){
		form = '[id^="edit_resource_"]'
		var resourceLocationsData = $('#resource_locations_data').data('resource-locations');
		$.each(resourceLocationsData, function(index,resourceLocation) {
			$('#resource_location_ids_'+resourceLocation.location_id).prop('checked', true);
			$('#resource_location_ids_quantity_'+resourceLocation.location_id).prop('disabled', false);
			$('#resource_location_ids_quantity_'+resourceLocation.location_id).val(resourceLocation.quantity);
		});
	}
	else {
		form = '#new_resource'
	}
}

var alertId;
$(function() {

	$('form input, form select').bind('keypress keydown keyup', function(e){
    	if(e.keyCode == 13) {
       		e.preventDefault();
       	}
    });

	alertId = new Alert();
	$('#newResourceCategoryButton').click(function() {
		getResourceCategories();
	});
	$('#resourceCategoryModal').on('hidden.bs.modal', function (e) {
		validator_resource_category.resetForm();
		$('.has-success').removeClass('has-success');
		$('.fa.fa-check').removeClass('fa fa-check');
		$('.has-error').removeClass('has-error');
		$('.fa.fa-times').removeClass('fa fa-times');
	});
	$('input.check_boxes').each(function () {
		var prop = true;
		$(this).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(this).parents('.panel').find('input[name="selectServiceCategory"]').prop('checked', prop);
	});
	$('input[name="selectServiceCategory"]').change(function (event) {
		var id = $(event.target).attr('id').replace('selectServiceCategory', '');
		$('#service_category' + id).find('input.check_boxes').each( function () {
			if ($(event.target).prop('checked')) {
				$(this).prop('checked', true);
			}
			else {
				$(this).prop('checked', false);
			}
		});
	});

	$('input.check_boxes').change(function (event) {
		var prop = true;
		$(event.target).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(event.target).parents('.panel').find('input[name="selectServiceCategory"]').prop('checked', prop);
	});
	initialize();
});
