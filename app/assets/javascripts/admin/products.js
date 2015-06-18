function changeLocationStatus(location_id) {
	if( $('#product_location_ids_'+location_id).prop('checked')) {
		$('#product_location_ids_stock_'+location_id).prop('disabled', false);
	}
	else {
		$('#product_location_ids_stock_'+location_id).prop('disabled', true);
		$('#product_location_ids_stock_'+location_id).val('');
	}
}

function saveCategory (typeURL, extraURL) {
	$('#saveProductCategryButton').attr('disabled', true);
	var categoryJSON = { "name": $('#product_category_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("Estás seguro?");
		if (r != true) {
		    return false;
		}
	}
	else if (!$('#new_product_category').valid()) {
		return false;
	};
	$.ajax({
		type: typeURL,
		url: '/product_categories'+extraURL+'.json',
		data: { "product_category": categoryJSON },
		dataType: 'json',
		success: function(product_category){
			switch(typeURL) {
			case 'POST':
				$('#product_product_category_id').append('<option value="'+product_category.id+'">'+product_category.name+'</option>');
				$('#product_product_category_id option[value="'+product_category.id+'"]').prop('selected', true);
				$('#productCategoryModal').modal('hide');
				$('#saveProductCategryButton').attr('disabled', false);
				break;
			case 'PATCH':
				$('#saveProductCategryButton').attr('disabled', false);
				break;
			case 'DELETE':
				$('#product_product_category_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#productCategoryModal').modal('hide');
				$('#saveProductCategryButton').attr('disabled', false);
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
			$('#saveProductCategryButton').attr('disabled', false);
		}
	});
}

function saveProduct (typeURL, extraURL) {
	if (!$(form).valid()) {
		return false;
	};
	$.each($('input[name="product[location_ids_stock][]"]'), function (key, product) {
		if (!$(product).attr('disabled')) {
			$(product).valid();
		};
	});
	if (validator_product.numberOfInvalids()) {
		return false;
	};
	var product_services = []
	$('input.productServiceCheck').each(function() {
		if ($(this).prop('checked')) {
	    	product_services.push($(this).val());
		}
	});
	var product_locations = []
	$('input.productLocationCheck').each(function() {
		if ($('#product_location_ids_'+$(this).val()).prop('checked')) {
	    	product_locations.push({ "location_id": $(this).val(), "stock": $('#product_location_ids_stock_'+$(this).val()).val() });
		}
	});
	var productJSON = { "name": $('#product_name').val(), "product_category_id": $('#product_product_category_id').val(), "service_ids": product_services, "product_locations_attributes": product_locations };
	$.ajax({
		type: typeURL,
		url: '/products'+extraURL+'.json',
		data: { "product": productJSON },
		dataType: 'json',
		success: function() {
			document.location.href = '/products/';
		},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errorList = '';
			for (i in errors) {
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

function getProductCategories() {
	$('#product_category_name').val('');
	$('#productCategoriesTable').empty();
	$.getJSON('/product_categories', function (categoriesArray) {
		$.each(categoriesArray, function (key, category) {
			var buttonString = '';
			if(category.name != "Otros") {
				buttonString = '<a class="btn btn-red" onclick="saveCategory(\'DELETE\',\'/'+category.id+'\')"><i class="fa fa-trash-o"></i></a>';
			}
			$('#productCategoriesTable').append('<tr><td>'+category.name+'</td><td>'+buttonString+'</td></tr>');
		});
		$('#productCategoryModal').modal('show');
	});
}
var form;
function initialize() {
	if ($("#id_data").length > 0){
		form = '[id^="edit_product_"]'
		var productLocationsData = $('#product_locations_data').data('product-locations');
		$.each(productLocationsData, function(index,productLocation) {
			$('#product_location_ids_'+productLocation.location_id).prop('checked', true);
			$('#product_location_ids_stock_'+productLocation.location_id).prop('disabled', false);
			$('#product_location_ids_stock_'+productLocation.location_id).val(productLocation.stock);
		});
	}
	else {
		form = '#new_product'
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
	$('#newProductCategoryButton').click(function() {
		getProductCategories();
	});
	$('#productCategoryModal').on('hidden.bs.modal', function (e) {
		validator_product_category.resetForm();
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
