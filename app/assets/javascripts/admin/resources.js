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
	$.ajax({
		type: typeURL,
		url: '/resource_categories'+extraURL+'.json',
		data: { "resource_category": categoryJSON },
		dataType: 'json',
		success: function(resource_category){
			switch(typeURL) {
			case 'POST':
				$('#resource_resource_category_id').append('<option value="'+resource_category.id+'">'+resource_category.name+'</option>');
				$('#resource_resource_category_id option[value="'+resource_category.id+'"]').attr('selected', true);
				$('#resourceCategoryModal').modal('hide');
				break;
			case 'PATCH':
				
				break;
			case 'DELETE':
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

$(function() {
	$('#newResourceCategoryButton').click(function() {
		getResourceCategories();
	});
	$('#saveResourceCategryButton').click(function() {
		saveCategory('POST','');
	});
	
});