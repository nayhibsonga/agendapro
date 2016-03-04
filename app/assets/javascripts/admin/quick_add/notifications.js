function loadNotifications() {
  var company = $('#notification_email_company_id').val();
  $.getJSON("/quick_add/load_notification_email_data", {company: company}, function (results) {
    // Static
    var localCheckboxName = "locations_ids";
    var providerCheckboxName = "service_provider_ids";

    // Clean state
    $('#local-notification').find('.checkbox').remove();
    $('#provider-notification').empty();
    $("#notification-emails-table>tbody").empty();

    // Results
    var locations = results.locations;
    var notifications = results.notifications;

    // Populate
    $('#provider-notification').append('<div class="row"></div>');
    var localGroup = $('#local-notification>div.form-group');
    $.each(locations, function (i, local) {
      var providerGroup = $('#provider-notification>div.row');
      localGroup.append(checkbox(localCheckboxName, local.id, local.name));
      providerGroup.append(
        '<div class="col-sm-4">\
          <div class="form-group">\
            <label for="notification_email_' + providerCheckboxName + '">' + local.name + '</label>\
            <input name="notification_email[' + providerCheckboxName + '][]" type="hidden" value>\
          </div>\
        </div>'
      );
      providerGroup = providerGroup.find(".form-group:last");
      $.each(local.service_providers, function (i, provider) {
        providerGroup.append(checkbox(providerCheckboxName, provider.id, provider.public_name));
      });
    });
    var notificationGroup = $("#notification-emails-table>tbody");
    $.each(notifications, function (i, notification) {
      notificationGroup.append(tableRow(notification));
    });

    // Show notifications
    $('#fieldset_step6').show();
    $('#fieldset_step6').attr('disabled', false);
    scrollToAnchor('fieldset_step6');
  });
}

function checkbox(name, id, text) {
  return $(
    '<div class="checkbox">\
      <label>\
        <input class="check_boxes" id="notification_email_' + name + '_' + id + '" name="notification_email[' + name + '][]" type="checkbox" value="' + id + '">' +
        text +
      '</label>\
    </div>'
  );
}

function tableRow(notification) {
  return $(
    '<tr class="notification-email-row" notification_id="' + notification.id + '">\
      <td>' + notification.email +'</td>\
      <td>' + notification.receptor_type_text + '</td>\
      <td>' + notification.notification_text + '</td>\
      <td style="white-space: nowrap;">\
        <button id="notification_email_delete_' + notification.id + '" class="btn btn-danger btn-xs notification-email-delete-btn"><i class="fa fa-trash-o"></i></button>\
      </td>\
    </tr>'
  );
}

function uncheckCheckbox () {
  var checkboxes = $('#provider-notification input[type="checkbox"], #local-notification input[type="checkbox"]');
  $.each(checkboxes, function (i, checkbox) {
    $(checkbox).prop('checked', false);
  });
}

$(function() {
  $('#update_notifications_button').click(function(){
    $('#quick_add_step7').show();
    scrollToAnchor('quick_add_step7');
  });

  $('#notification_email_receptor_type').change(function () {
    var val = $(this).val();
    if (val == 1) {
      $('#local-notification').removeClass('hidden');
      if (!$('#provider-notification').hasClass('hidden')) {
        $('#provider-notification').addClass('hidden');
        uncheckCheckbox();
      }
    } else if (val == 2) {
      $('#provider-notification').removeClass('hidden');
      if (!$('#local-notification').hasClass('hidden')) {
        $('#local-notification').addClass('hidden');
        uncheckCheckbox();
      }
    } else{
      if (!$('#provider-notification').hasClass('hidden')) {
        $('#provider-notification').addClass('hidden');
        uncheckCheckbox();
      }
      if (!$('#local-notification').hasClass('hidden')) {
        $('#local-notification').addClass('hidden');
        uncheckCheckbox();
      }
    }
  });

  $("#addNotificationBtn").on('click', function(e){
    e.preventDefault();
    var data = $("#new_notification_email").serializeArray();
    $.ajax({
      url: '/create_notification_email',
      type: 'post',
      dataType: 'json',
      data: data,
      error: function(response){

      },
      success: function(response){
        notification_email = response.notification_email;
        console.log(notification_email);
        console.log(response);
        $("#notification-emails-table>tbody").append(tableRow(notification_email));
      }
    });
  });

  $('body').on('click', '.notification-email-delete-btn', function(){
    var id = $(this).attr("id").split("_")[3];
    $.ajax({
      url: '/delete_notification_email',
      type: 'post',
      dataType: 'json',
      data: {id: id},
      error: function(response){

      },
      success: function(response){
        if(response.status != "error")
        {
          $('.notification-email-row[notification_id="' + id + '"]').remove();
        }
      }
    })
  });
});
