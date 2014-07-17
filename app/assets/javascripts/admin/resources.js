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
	var categoryJSON = { "name": $('#resource_category_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("Estás seguro?");
		if (r != true) {
		    return false;
		}
	}
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
				break;
			case 'PATCH':
				
				break;
			case 'DELETE':
				$('#resource_resource_category_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#resourceCategoryModal').modal('hide');
				break;
			}
		},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errores = '';
			for (i in errors) {
				errores += errors[i];
			}
			alert(errores);
		}
	});
}

function saveResource (typeURL, extraURL) {
	if (!$('form').valid()) {
		return false;
	};
	$.each($('input[name="resource[location_ids_quantity][]"]'), function (key, resource) {
		if (!$(resource).attr('disabled')) {
			$(resource).valid();
		};
	});
	if (validator.numberOfInvalids()) {
		return false;
	};

	var resource_locations = []
	$('input.resourceLocationCheck').each(function(i, obj) {
		window.console.log(obj.value);
		if ($('#resource_location_ids_'+obj.value).prop('checked')) {
	    	resource_locations.push({ "location_id": obj.value, "quantity": $('#resource_location_ids_quantity_'+obj.value).val() });
		}
	});
	var resourceJSON = { "name": $('#resource_name').val(), "resource_category_id": $('#resource_resource_category_id').val(), "resource_locations_attributes": resource_locations };
	$.ajax({
		type: typeURL,
		url: '/resources'+extraURL+'.json',
		data: { "resource": resourceJSON },
		dataType: 'json',
		success: function() {
				document.location.href = '/resources/';
			},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errores = '';
			for (i in errors) {
				errores += errors[i];
			}
			alertId.showAlert(errores);
		}
	});
}

function getResourceCategories() {
	// $('#resourceCategoriesTable').html('<tr><th>Categoría</th><th>Eliminar</th></tr>');
	$('#resource_category_name').val('');
	$('#resourceCategoriesTable').empty();
	$.getJSON('/resource_categories', function (categoriesArray) {
		$.each(categoriesArray, function (key, category) {
			var buttonString = '';
			if(category.name != "Sin Categoría") {
				buttonString = '<a class="btn btn-danger" onclick="saveCategory(\'DELETE\',\'/'+category.id+'\')"><i class="fa fa-trash-o"></i></a>';
			}
			$('#resourceCategoriesTable').append('<tr><td>'+category.name+'</td><td>'+buttonString+'</td></tr>');
		});
		$('#resourceCategoryModal').modal('show');
	});
}

function initialize() {
	if ($("#id_data").length > 0){
		$('#saveResourceButton').click(function() {
			saveResource('PATCH','/'+$("#id_data").data('id'));
		});
		var resourceLocationsData = $('#resource_locations_data').data('resource-locations');
		$.each(resourceLocationsData, function(index,resourceLocation) {
			$('#resource_location_ids_'+resourceLocation.location_id).prop('checked', true);
			$('#resource_location_ids_quantity_'+resourceLocation.location_id).prop('disabled', false);
			$('#resource_location_ids_quantity_'+resourceLocation.location_id).val(resourceLocation.quantity);
		});
	}
	else {
		$('#saveResourceButton').click(function() {
			saveResource('POST','');
		});
	}
}

var alertId;
$(function() {
	alertId = new Alert();
	$('#newResourceCategoryButton').click(function() {
		getResourceCategories();
	});
	$('#saveResourceCategryButton').click(function() {
		saveCategory('POST','');
	});
	initialize();
});