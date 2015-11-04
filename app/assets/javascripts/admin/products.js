function changeLocationStatus(location_id) {
	if( $('#location_product_ids_'+location_id).prop('checked')) {
		$('#location_product_ids_stock_'+location_id).prop('disabled', false);
	}
	else {
		$('#location_product_ids_stock_'+location_id).prop('disabled', true);
		$('#location_product_ids_stock_'+location_id).val('');
	}
}

function saveCategory (typeURL, extraURL) {
	$('#saveProductCategoryButton').attr('disabled', true);
	var categoryJSON = { "name": $('#product_category_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("¿Estás seguro?");
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
				$('#saveProductCategoryButton').attr('disabled', false);
				break;
			case 'PATCH':
				$('#saveProductCategoryButton').attr('disabled', false);
				break;
			case 'DELETE':
				$('#product_product_category_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#productCategoryModal').modal('hide');
				$('#saveProductCategoryButton').attr('disabled', false);
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
			$('#saveProductCategoryButton').attr('disabled', false);
		}
	});
}

function saveBrand (typeURL, extraURL) {
	$('#saveProductBrandButton').attr('disabled', true);
	var brandJSON = { "name": $('#product_brand_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("¿Estás seguro?");
		if (r != true) {
		    return false;
		}
	}
	else if (!$('#new_product_brand').valid()) {
		return false;
	};
	$.ajax({
		type: typeURL,
		url: '/product_brands'+extraURL+'.json',
		data: { "product_brand": brandJSON },
		dataType: 'json',
		success: function(product_brand){
			switch(typeURL) {
			case 'POST':
				$('#product_product_brand_id').append('<option value="'+product_brand.id+'">'+product_brand.name+'</option>');
				$('#product_product_brand_id option[value="'+product_brand.id+'"]').prop('selected', true);
				$('#productBrandModal').modal('hide');
				$('#saveProductBrandButton').attr('disabled', false);
				break;
			case 'PATCH':
				$('#saveProductBrandButton').attr('disabled', false);
				break;
			case 'DELETE':
				$('#product_product_brand_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#productBrandModal').modal('hide');
				$('#saveProductBrandButton').attr('disabled', false);
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
			$('#saveProductBrandButton').attr('disabled', false);
		}
	});
}

function saveDisplay (typeURL, extraURL) {
	$('#saveProductDisplayButton').attr('disabled', true);
	var displayJSON = { "name": $('#product_display_name').val() };
	if (typeURL == 'DELETE') {
		var r = confirm("¿Estás seguro?");
		if (r != true) {
		    return false;
		}
	}
	else if (!$('#new_product_display').valid()) {
		return false;
	};
	$.ajax({
		type: typeURL,
		url: '/product_displays'+extraURL+'.json',
		data: { "product_display": displayJSON },
		dataType: 'json',
		success: function(product_display){
			switch(typeURL) {
			case 'POST':
				$('#product_product_display_id').append('<option value="'+product_display.id+'">'+product_display.name+'</option>');
				$('#product_product_display_id option[value="'+product_display.id+'"]').prop('selected', true);
				$('#productDisplayModal').modal('hide');
				$('#saveProductDisplayButton').attr('disabled', false);
				break;
			case 'PATCH':
				$('#saveProductDisplayButton').attr('disabled', false);
				break;
			case 'DELETE':
				$('#product_product_display_id option[value="'+extraURL.substring(1)+'"]').remove();
				$('#productDisplayModal').modal('hide');
				$('#saveProductDisplayButton').attr('disabled', false);
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
			$('#saveProductDisplayButton').attr('disabled', false);
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
	var location_products = []
	
	/*$('input.productLocationCheck').each(function() {
		if ($('#location_product_ids_'+$(this).val()).prop('checked')) {
	    	location_products.push({ "location_id": $(this).val(), "stock": $('#location_product_ids_stock_'+$(this).val()).val() });
		}
	});*/

	$('.location_product_stock').each(function(){
		location_products.push({ "location_id": $(this).attr("location_id"), "stock": $(this).val()});
	});

	console.log(location_products);

	var product_description = $("#product_description").val();

	var productJSON = { "name": $('#product_name').val(), "sku": $('#product_sku').val(), "product_category_id": $('#product_product_category_id').val(), "product_brand_id": $('#product_product_brand_id').val(), "product_display_id": $('#product_product_display_id').val(), "price": $('#product_price').val(), "comission_value": $('#product_comission_value').val(), "comission_option": $('#product_comission_option').val(), "description": product_description, "cost": $("#product_cost").val(), "internal_price": $("#product_internal_price").val() };
	$.ajax({
		type: typeURL,
		url: '/products'+extraURL+'.json',
		data: { "product": productJSON, "location_products": JSON.stringify(location_products)},
		dataType: 'json',
		success: function() {
			alertId.showAlert(
				'<h3>Producto guardado</h3>' +
				'<p>El producto se ha editado de manera correcta.</p>'
				,
				function(){
					document.location.href = '/products/';
				}
				,
				"Aceptar"
				,
				function(){
					document.location.href = '/products/';
				}
			);
			
		},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
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

function getProductBrands() {
	$('#product_brand_name').val('');
	$('#productBrandsTable').empty();
	$.getJSON('/product_brands', function (brandsArray) {
		$.each(brandsArray, function (key, brand) {
			var buttonString = '';
			if(brand.name != "Otros") {
				buttonString = '<a class="btn btn-red" onclick="saveBrand(\'DELETE\',\'/'+brand.id+'\')"><i class="fa fa-trash-o"></i></a>';
			}
			$('#productBrandsTable').append('<tr><td>'+brand.name+'</td><td>'+buttonString+'</td></tr>');
		});
		$('#productBrandModal').modal('show');
	});
}

function getProductDisplays() {
	$('#product_display_name').val('');
	$('#productDisplaysTable').empty();
	$.getJSON('/product_displays', function (displaysArray) {
		$.each(displaysArray, function (key, display) {
			var buttonString = '';
			if(display.name != "Otros") {
				buttonString = '<a class="btn btn-red" onclick="saveDisplay(\'DELETE\',\'/'+display.id+'\')"><i class="fa fa-trash-o"></i></a>';
			}
			$('#productDisplaysTable').append('<tr><td>'+display.name+'</td><td>'+buttonString+'</td></tr>');
		});
		$('#productDisplayModal').modal('show');
	});
}

function getInventory()
{
	var location_id = $("#locationsSelect").val();
	var location_name = $("#locationsSelect option:selected").text();
	var category = $("#categoryFilterSelect").val();
	var brand = $("#brandFilterSelect").val();
	var display = $("#displayFilterSelect").val();

	if(location_id == "0")
	{
		$.ajax({
			url: '/company_inventory',
			type: 'get',
			data: {category: category, brand: brand, display: display},
			success: function(response)
			{
				$("#locationInventory").empty();
				$("#locationInventory").append(response);
				$("#selectedLocationInventory").html(" todos los locales");
			}
		});
	}
	else
	{
		$.ajax({
			url: '/inventory',
			type: 'get',
			data: {id: location_id, category: category, brand: brand, display: display},
			success: function(response)
			{
				$("#locationInventory").empty();
				$("#locationInventory").append(response);
				$("#selectedLocationInventory").html(location_name);
			}
		});
	}
}

var form;
function initialize() {
	if ($("#id_data").length > 0){
		form = '[id^="edit_product_"]'
		var productLocationsData = $('#location_products_data').data('location-products');
		$.each(productLocationsData, function(index,productLocation) {
			$('#location_product_ids_'+productLocation.location_id).prop('checked', true);
			$('#location_product_ids_stock_'+productLocation.location_id).prop('disabled', false);
			$('#location_product_ids_stock_'+productLocation.location_id).val(productLocation.stock);
		});
	}
	else {
		form = '#new_product'
	}

	$("#locationsSelect").trigger('change');
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
	$("#newProductBrandButton").click(function(){
		getProductBrands();
	});
	$("#newProductDisplayButton").click(function(){
		getProductDisplays();
	});
	$('#openCategoriesBtn').click(function(e) {
		e.preventDefault();
		getProductCategories();
	});
	$("#openBrandsBtn").click(function(e){
		e.preventDefault();
		getProductBrands();
	});
	$("#openDisplaysBtn").click(function(e){
		e.preventDefault();
		getProductDisplays();
	});

	$('#productCategoryModal').on('hidden.bs.modal', function (e) {
		validator_product_category.resetForm();
		$('.has-success').removeClass('has-success');
		$('.fa.fa-check').removeClass('fa fa-check');
		$('.has-error').removeClass('has-error');
		$('.fa.fa-times').removeClass('fa fa-times');
	});
	$('#productBrandModal').on('hidden.bs.modal', function (e) {
		validator_product_brand.resetForm();
		$('.has-success').removeClass('has-success');
		$('.fa.fa-check').removeClass('fa fa-check');
		$('.has-error').removeClass('has-error');
		$('.fa.fa-times').removeClass('fa fa-times');
	});
	$('#productDisplayModal').on('hidden.bs.modal', function (e) {
		validator_product_display.resetForm();
		$('.has-success').removeClass('has-success');
		$('.fa.fa-check').removeClass('fa fa-check');
		$('.has-error').removeClass('has-error');
		$('.fa.fa-times').removeClass('fa fa-times');
	});

	$("#product_cost").on('change', function(){
		var cost = parseFloat($(this).val());
		var internal_price = cost*1.19;
		$("#product_internal_price").val(internal_price);
	})

	$('#locationsSelect').on('change', function(){
		getInventory();
		if($("#locationsSelect").val() == "0")
		{
			$("#openAlarmsBtn").hide();
		}
		else
		{
			$("#openAlarmsBtn").show();
		}
	});

	$(".filterSelect").on('change', function(){
		getInventory();
	});

	$("body").on('click', '.btn-alarm', function(e){

		e.preventDefault();
		var location_product_id = $(this).attr("location_product_id");
		
		$.ajax({
			url: '/alarm_form?location_product_id=' + location_product_id,
			type: 'get',
			success: function(response){
				$("#location_product_id").val(location_product_id);
				$("#location_product_stock_limit").val(response[0]);
				$("#location_product_alarm_email").val(response[1]);
				$("#productAlarmModal").modal('show');
			}
		});
	});

	$("body").on('click', '#saveAlarmBtn', function(e){
		e.preventDefault();
		var location_product_id = $("#location_product_id").val();
		var stock_limit = $("#location_product_stock_limit").val();
		var alarm_email = $("#location_product_alarm_email").val();

		$.ajax({
			url: '/set_alarm',
			type: 'post',
			dataType: 'json',
			data: {location_product_id: location_product_id, stock_limit: stock_limit, alarm_email: alarm_email},
			success: function(response){
				if(response[0] == "ok")
				{
					alertId.showAlert(
						'<h3>Alarma guardada</h3>' +
						'<p>Se ha guardado la alarma correctamente.</p>'
					);
					console.log(response[1]['stock']);
					console.log(response[1]['stock_limit']);
					console.log(response[1]['stock'] < response[1]['stock_limit']);
					console.log(response[1]['product_id']);
					if( response[1]['stock'] < response[1]['stock_limit'] )
					{
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').removeClass("mediumStock");
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').addClass("lowStock");
					}
					else if( response[1]['stock'] < response[1]['stock_limit'] * 1.5 )
					{
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').addClass("mediumStock");
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').removeClass("lowStock");
					}
					else
					{
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').removeClass("mediumStock");
						$('.inventoryRow[product_id="' + response[1]['product_id'] + '"]').removeClass("lowStock");
					}
				}
				else
				{
					errors = response[1];
					errorList = '';
					for (i in errors) {
						errorList += '<li>' + errores[i] + '</li>'
					}
					alertId.showAlert(
						'<h3>Error</h3>' +
						'<p>Ocurrió un error al guardar la alarma:</p>' + 
						'<p><ul>' + errorList + '</ul></p>'
					);
				}
				$("#productAlarmModal").modal('hide');
				$("#location_product_id").val('');
				$("#location_product_alarm_email").val('');
				$("#location_product_stock_limit").val('');
			},
			error: function(response)
			{
				alertId.showAlert(
					'<h3>Error</h3>' +
					'<p>Ocurrió un error inesperado al guardar la alarma.</p>'
				);
				$("#productAlarmModal").modal('hide');
				$("#location_product_id").val('');
				$("#location_product_alarm_email").val('');
				$("#location_product_stock_limit").val('');
			}
		});

	});


	$("body").on('click', '#openImportBtn', function(e){
		$('#importModal').modal('show');
	});

	$('#file').change( function () {
		if ($('#file').val()) {
			$('#import_button').removeAttr("disabled");
		}
		else {
			$('#import_button').attr("disabled", "disabled");
		}
	});

	$("body").on('click', '#openAlarmsBtn', function(e){
		e.preventDefault();
		var location_id = $("#locationsSelect").val();
		if(location_id != "0")
		{
			$.ajax({
				url: '/location_alarms',
				type: 'get',
				data: {id: location_id},
				success: function(response)
				{
					$("#AlarmsModalDiv").empty();
					$("#AlarmsModalDiv").append(response);
					$("#generalAlarmsModal").modal("show");
				}
			});
		}
		else
		{
			$("#AlarmsModalDiv").empty();
			$("#generalAlarmsModal").modal("show");
		}
	});

	$("#saveGeneralAlarmsBtn").click(function(e){

		var stock_alarm_setting_id = $("#stockAlarmSettingId").val();
		var quick_send = $("#location_quick_send").val();
		var periodic_send = $("#location_periodic_send").val();
		var has_default_stock_limit = $("#location_has_default_stock_limit").val();
		var default_stock_limit = $("#location_default_stock_limit").val();
		var monthly = $("#location_monthly").val();
		var month_day = $("#location_month_day").val();
		var week_day = $("#location_week_day").val();
		var email = $("#location_email").val();

		$.ajax({
			url: '/save_alarms',
			type: 'post',
			dataType: 'json',
			data: {stock_alarm_setting_id: stock_alarm_setting_id, quick_send: quick_send, periodic_send: periodic_send, has_default_stock_limit: has_default_stock_limit, default_stock_limit: default_stock_limit, monthly: monthly, month_day: month_day, week_day: week_day, email: email},
			success: function(response){
				$("#generalAlarmsModal").modal('hide');
				if(response[0] == "ok")
				{
					alertId.showAlert(
						'<h3>Alarmas guardadas</h3>' +
						'<p>Se han guardado la alarmas correctamente.</p>'
					);
				}
				else
				{
					errors = response[1];
					errorList = '';
					for (i in errors) {
						errorList += '<li>' + errores[i] + '</li>'
					}
					alertId.showAlert(
						'<h3>Error</h3>' +
						'<p>Ocurrió un error al guardar las alarmas:</p>' + 
						'<p><ul>' + errorList + '</ul></p>'
					);
				}	
			}
		});

	});

	initialize();
});
