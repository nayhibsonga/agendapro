$(function() {
	if ($('#user_role_id').val() == 4) {
		$('#locationGroup').addClass('hidden');
		$('#providerGroup').removeClass('hidden');
	}
	else {
		$('#locationGroup').removeClass('hidden');
		$('#providerGroup').addClass('hidden');
	}
	$('#user_role_id').change(function() {
		if ($('#user_role_id').val() == 4 || $('#user_role_id').val() == 7) {
			$('#locationGroup').addClass('hidden');
			$('#user_location_id').val('');
			$('#providerGroup').removeClass('hidden');
		}
		else {
			$('#locationGroup').removeClass('hidden');
			$('input.check_boxes').each(function() {
				$(this).prop('checked',false);
				var prop = true;
				$(this).parents('.panel-body').find('input.check_boxes').each( function () {
					prop = prop && $(this).prop('checked');
				});
				$(this).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
			});
			$('#providerGroup').addClass('hidden');
		}
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
	$('input.check_boxes').each(function () {
		var prop = true;
		$(this).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(this).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
	});
	$('input.check_boxes').change(function (event) {
		var prop = true;
		$(event.target).parents('.panel-body').find('input.check_boxes').each( function () {
			prop = prop && $(this).prop('checked');
		});
		$(event.target).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
	});
});