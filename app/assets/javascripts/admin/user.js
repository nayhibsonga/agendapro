$(function() {
  compose_name('#user_full_name', '#user_first_name', '#user_last_name');
  split_name('#user_full_name', '#user_first_name', '#user_last_name');

  if ($("#user_role_id option:selected").text() == "Staff" || $("#user_role_id option:selected").text() == "Staff (sin edición)") {
    $('#locationGroup').addClass('hidden');
    $('#providerGroup').removeClass('hidden');
  } else {
    $('#locationGroup').removeClass('hidden');
    $('#providerGroup').addClass('hidden');
  }
  $('#user_role_id').change(function() {
    if ($("#user_role_id option:selected").text() == "Staff" || $("#user_role_id option:selected").text() == "Staff (sin edición)") {
      $('#locationGroup').addClass('hidden');
      $('#providerGroup').removeClass('hidden');
    } else {
      $('#locationGroup').removeClass('hidden');
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
