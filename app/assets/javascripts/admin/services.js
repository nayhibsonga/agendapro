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
		$('#service_capacity').attr('disabled', false);
	}
	else {
		$('#service_capacity').closest('.form-group').addClass('hidden');
		$('#service_capacity').attr('disabled', true);
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
		var id = $(event.target).attr('id').replace('selectResourceCategory', '');
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

	$('#saveServiceCategryButton').click(function () {
		if ($('#new_service_category').valid()) {
			var btn = $(this)
			btn.button('loading')
			$.ajax({
				type: 'POST',
				url: '/service_categories.json',
				data: { "service_category": { "name": $('#service_category_name').val() } },
				dataType: 'json',
				success: function(service_category){
					$('#service_service_category_id').append('<option value="'+service_category.id+'">'+service_category.name+'</option>');
					$('#service_service_category_id option[value="'+service_category.id+'"]').prop('selected', true);
					$('#serviceCategoryModal').modal('hide');
				},
				error: function(xhr){
					var errors = $.parseJSON(xhr.responseText).errors;
					var errores = 'Error\n';
					for (i in errors) {
						errores += '*' + errors[i] + '\n';
					}
					alert(errores);
				},
			}).always(function () {
				btn.button('reset');
				$('#service_category_name').val('');
			});
		};
	});
	$('#service_company_id').change(function() {
		$.getJSON('/service_categories', { company_id: $('#service_company_id').val() }, function (service_categories) {

			$('#service_service_category_id').find('option').remove().end();
			$.each(service_categories, function (key, service_category) {
				$('#service_service_category_id').append(
					'<option value="' + service_category.id + '">' + service_category.name + '</option>'
				);
			});
			$('#region').prepend(
				'<option></option>'
			);
		});
	});

	$('#serviceCategoryModal').on('hidden.bs.modal', function (e) {
		validator.resetForm();
		$('.has-success').removeClass('has-success');
		$('.fa.fa-check').removeClass('fa fa-check');
		$('.has-error').removeClass('has-error');
		$('.fa.fa-times').removeClass('fa fa-times');
	});
});
