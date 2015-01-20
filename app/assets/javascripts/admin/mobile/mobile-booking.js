function loadServices (provider) {
  $('#booking_service').prop('disabled', true);
  $.getJSON('/provider_services', {id: provider}, function (services) {
    $('#booking_service').empty();
    $.each(services, function (key, service) {
      $('#booking_service').append(
        '<option value="' + service.id + '">' + service.name + '</option>'
      );
    });
  }).always(function () {
    $('#booking_service').prop('disabled', false);
  });
}

function loadServiceData (service_id) {
  $.getJSON('/services/' + service_id, function (service) {
    // Price
    $('#booking_price').val(service.price);

    //End time
    var date = $('#date').val().split('-');
    var time = $('#start').val().split(':');
    var d = new Date(date[0], date[1], date[2], time[0], time[1]);
    d.setMinutes(d.getMinutes() + service.duration);
    var hour = d.getHours(), min = d.getMinutes();
    if (hour < 10) {
      hour = '0' + hour;
    };
    if (min < 10) {
      min = '0' + min;
    };
    $('#end').val(hour + ':' + min);
  });
}

function saveBooking (typeURL, booking_id) {
  var date = $('#date').val().split('-');
  var JSONData = {
    'start': date[2] + '/' + date[1] + '/' + date[0] + 'T' + $('#start').val() + ':00Z',
    'end': date[2] + '/' + date[1] + '/' + date[0] + 'T' + $('#end').val() + ':00Z',
    'service_provider_id': $('#booking_service_provider').val(),
    'service_id': $('#booking_service').val(),
    'status_id': $('#booking_status').val(),
    'client_id': $('#booking_client').val(),
    'price': $('#booking_price').val(),
    'client_first_name': $('#first_name').val(),
    'client_last_name': $('#last_name').val(),
    'client_email': $('#email').val(),
    'client_phone': $('#phone').val(),
    'send_mail': $('#send_mail').prop('checked'),
    "client_identification_number": $('#identification_number').val(),
    "staff_code": $('#booking_staff_code').val()
  }
  $.ajax({
    type: typeURL,
    url: '/bookings' + booking_id + '.json',
    data: {
      "booking": JSONData
    },
    dataType: 'json',
    success: function(booking){
      window.location.href = "/bookings/"
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors;
      var errores = 'Error\n';
      for (i in errors) {
        errores += '*' + errors[i] + '\n';
      }
      $('button[type="submit"]').button('reset');
      alert(errores);
    }
  });
}

$(function () {
  split_name ('#name', '#first_name', '#last_name');

  $('#booking_service_provider').change(function (event) {
    var provider_id = $(this).val();
    loadServices(provider_id);
  });

  $('#booking_service').change(function (event) {
    var service_id = $(this).val();
    loadServiceData(service_id);
  })

  $('button[type="submit"]').click(function (event) {
    event.preventDefault();
    $(this).button('loading');
    var booking = '';
    if ($(this).data('id')) {
      booking = '/' + $(this).data('id');
    };
    var url = $(this).data('url');
    saveBooking(url, booking);
  });
});
