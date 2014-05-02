function categoryChange() {
	if ($('#categoryCheckboxId').val() == 1) {
		$('#categoryCheckboxId').val(0);
		$('#service_service_category_id').prop('disabled', false);
		$('#service_service_category_id').closest('.form-group').removeClass('hidden');
		$('#service_service_category_attributes_name').val('');
		$('#service_service_category_attributes_name').prop('disabled', true);
		$('#service_service_category_attributes_name').closest('.form-group').addClass('hidden');
	}
	else if ($('#categoryCheckboxId').val() == 0) {
		$('#categoryCheckboxId').val(1);
		$('#service_service_category_attributes_name').prop('disabled', false);
		$('#service_service_category_attributes_name').closest('.form-group').removeClass('hidden');
		$('#service_service_category_id').val('');
		$('#service_service_category_id').prop('disabled', true);
		$('#service_service_category_id').closest('.form-group').addClass('hidden');
	}
}

$(function() {
	$('#service_service_category_attributes_name').prop('disabled', true);
	$('#service_group_service').click(function (e) {
		serviceGroup();
	});
	$('#categoryCheckboxId').click(function (e) {
		categoryChange();
	});
	if ($('#service_group_service').is(':checked')) {
		$('#service_capacity').closest('.form-group').removeClass('hidden');
		$('#foo5').trigger('updateSizes');
	}
});

function serviceGroup () {
	if ($('#service_group_service').is(':checked')) {
		$('#service_capacity').closest('.form-group').removeClass('hidden');
		$('#foo5').trigger('updateSizes');
	}
	else {
		$('#service_capacity').closest('.form-group').addClass('hidden');
	}
}
