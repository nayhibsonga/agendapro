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

function serviceGroup () {
	if ($('#service_group_service').is(':checked')) {
		$('#service_capacity').closest('.form-group').removeClass('hidden');
		$('#foo5').trigger('updateSizes');
	}
	else {
		$('#service_capacity').closest('.form-group').addClass('hidden');
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
	if ($('#service_outcall').prop('checked')) {
		$('#outcallTip').removeClass('hidden');
	}
	$('input.check_boxes').each(function () {
		var prop = true;
		$(this).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(this).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
	});
	$('input[name="selectLocation"]').change(function (event) {
		var id = $(event.target).attr('id').replace('selectLocation', '');
		$('#location' + id).find('input.check_boxes').each( function () {
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
		$(event.target).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
	});

	$('input.check_boxes').each(function () {
		var prop = true;
		$(this).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(this).parents('.panel').find('input[name="selectResourceCategory"]').prop('checked', prop);
	});
	$('input[name="selectResourceCategory"]').change(function (event) {
		var id = $(event.target).attr('id').replace('selectLocation', '');
		$('#resource_category' + id).find('input.check_boxes').each( function () {
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
		$(event.target).parents('.panel').find('input[name="selectResourceCategory"]').prop('checked', prop);
	});
	$('#service_outcall').change(function() {
		if (!$('#service_outcall').prop('checked')) {
			$('#outcallTip').addClass('hidden');
		}
		else {
			$('#outcallTip').removeClass('hidden');
		}
	});
});
