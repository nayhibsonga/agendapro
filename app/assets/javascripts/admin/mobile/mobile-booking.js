function loadServices (provider) {
  var selectedService =  $('#booking_service').val();
  $('#booking_service').prop('disabled', true);
  $.getJSON('/provider_services', {id: provider}, function (services) {
    $('#booking_service').empty();
    $.each(services, function (key, service) {
      $('#booking_service').append(
        '<option value="' + service.id + '">' + service.name + '</option>'
      );
    });
    $('#booking_service option[value="' + selectedService + '"]').prop('selected', true);
  }).always(function () {
    $('#booking_service').prop('disabled', false);
  });

  checkClientSessions();

}

function jsonAttributes()
{
  var jsAttributes = {};
  $('.custom-attribute').each(function(){
    var attribute_name = $(this).attr("name");
    var attribute_val = $(this).val();
    jsAttributes[attribute_name] = attribute_val;
  });
  return jsAttributes;
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

  checkClientSessions();

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
    "staff_code": $('#booking_staff_code').val(),
    "notes": $('#booking_notes').val(),
    "company_comment": $('#booking_company_comment').val()
  }

  if($("#has_sessions").val() == "1")
  {
    JSONData["session_booking_id"] = $('[name="sessions-choice"]:checked').val();
  }

  var bookingJSON = {"bookings": [JSONData], "custom_attributes": attributesJSON };
  if (typeURL != 'POST') {
    bookingJSON = {"booking": JSONData};
  }

  var attributesJSON = jsonAttributes();

  $.ajax({
    type: typeURL,
    url: '/bookings' + booking_id + '.json',
    data: bookingJSON,
    dataType: 'json',
    success: function(booking){
      var book = booking;
      if (Array.isArray(booking)) {
        book = booking[0];
      }
      window.location.href = "/bookings?" + $.param({
        local: book.location_id,
        provider: book.service_provider_id,
        date: book.start
      });
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors[0].errors;
      var errores = '';
      for (i in errors) {
        errores += '*' + errors[i] + '\n';
      }
      $('button[type="submit"]').removeClass('disabled');
      $('button[type="submit"]').html('Guardar');
      swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n" + errores,
        type: "error"
      });
    }
  });
}

function validateMail () {
  var $regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  var $email = $('#email').val();

  if ($email != '' && $regex.test($email)) {
    $('#send_mail').prop('checked', true);
    window.console.log(true)
  } else {
    $('#send_mail').prop('checked', false);
    window.console.log(false)
  };
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
  });

  $('#start').change(function () {
    var service_id = $('#booking_service').val();
    loadServiceData(service_id);
  });

  $('button[type="submit"]').click(function (event) {
    event.preventDefault();
    if ($('form').valid()) {
      $(this).addClass('disabled');
      $(this).html($(this).data('loading'));
      var booking = '';
      if ($(this).data('id')) {
        booking = '/' + $(this).data('id');
      };
      var url = $(this).data('url');
      saveBooking(url, booking);
    };
  });

  $('#email').change(function (event) {
    validateMail();
    checkClientSessions();
  });

  $('#name').autocomplete({
    source: '/clients_name_suggestion',
    appendTo: '#name_suggestion',
    position: {my: "right top", at: "right bottom", collision: "none"},
    autoFocus: true,
    minLength: 3,
    select: function (event, ui) {
      event.preventDefault();
      var client = eval("(" + ui.item.value + ")");

      var custom_attributes = ui.item.custom_attributes;

      for(var key in custom_attributes)
      {
        console.log(key);
        console.log(custom_attributes[key]);
        $('[name="' + key + '"]').val(custom_attributes[key]);
      }

      console.log(custom_attributes);

      $('#name').val(client.first_name + ' ' + client.last_name);
      $('#name').prop('disabled', true);
      $('#clear').prop('disabled', false);
      $('#booking_client').val(client.id);
      $('#first_name').val(client.first_name);
      $('#last_name').val(client.last_name);
      $('#email').val(client.email);
      $('#phone').val(client.phone);
      $('#identification_number').val(client.identification_number);
      $('#name').blur();
      validateMail();
      checkClientSessions();
    },
    open: function(event, ui)
    {
      $(".ui-helper-hidden-accessible").hide();
    }
  }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    return $( '<li>' ).append( '<a>' + item.label + '<br><span class="auto-desc">' + item.desc + '</span></a>' ).appendTo( ul );
  };

  $('#email').autocomplete({
    source: '/clients_suggestion',
    appendTo: '#email_suggestion',
    position: {my: "right top", at: "right bottom", collision: "none"},
    autoFocus: true,
    minLength: 3,
    select: function (event, ui) {
      event.preventDefault();
      var client = eval("(" + ui.item.value + ")");
      $('#name').val(client.first_name + ' ' + client.last_name);
      $('#name').prop('disabled', true);
      $('#clear').prop('disabled', false);
      $('#booking_client').val(client.id);
      $('#first_name').val(client.first_name);
      $('#last_name').val(client.last_name);
      $('#email').val(client.email);
      $('#phone').val(client.phone);
      $('#identification_number').val(client.identification_number);
      $('#email').blur();
      validateMail();
      checkClientSessions();
      $(".ui-helper-hidden-accessible").hide();
    },
    open: function(event, ui)
    {
      $(".ui-helper-hidden-accessible").hide();
    }
  }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    return $( '<li>' ).append( '<a>' + item.label + '<br><span class="auto-desc">' + item.desc + '</span></a>' ).appendTo( ul );
  };

  $('#clear').click(function (event) {
    $('.custom-attribute').each(function(){
      $(this).val('');
    });
    $(this).prop('disabled', true);
    $('#name').prop('disabled', false);
    $('#booking_client').val('');
    $('#name').val('');
    $('#email').val('');
    $('#send_mail').prop('checked', false);
    $('#phone').val('');
    checkClientSessions();
  });
});

function checkClientSessions()
{
  //modalChange();
  if($("#is_edit_modal").val() == "0")
  {

    $("#sessions-info").empty();
    $("#sessions-row").hide();
    $("#add-service-btn").show();
    $("#has_sessions").val("0");

    if (parseInt($('#booking_client').val()) > 0)
    {
      if(parseInt($("#booking_service").val()) > 0)
      {
        $.ajax({
          type: "get",
          url: "/clients_check_sessions?id=" + $('#booking_client').val() + "&service_id=" + $("#booking_service").val(),
          success: function(response)
          {
            var service = response[0]
            var sessions_bookings = response[1]

            if (service.has_sessions)
            {
              if (sessions_bookings.length > 0)
              {
                $("#sessions-info").append('<div session_booking_id="0"><input type="radio" name="sessions-choice" value="0" />&nbsp;Generar una nueva reserva y agendar la primera sesión.');
              }
              else
              {
                $("#sessions-info").append('<div session_booking_id="0"><input type="radio" name="sessions-choice" value="0" checked>&nbsp;Generar una nueva reserva y agendar la primera sesión.');
              }
              $("#sessions-row").show();
              $("#add-service-btn").hide();
              $("#has_sessions").val("1");
              if(sessions_bookings.length > 0)
              {
                var index = 0;
                $.each(sessions_bookings, function (key, session_booking) {
                  var nextSession = session_booking.sessions_taken + 1;
                  if(index == 0)
                  {
                    $("#sessions-info").append('<div session_booking_id="' + session_booking.id + '"><input type="radio" name="sessions-choice" value="' + session_booking.id + '" checked />&nbsp;El cliente ha agendado ' + session_booking.sessions_taken + ' de un total de ' + session_booking.sessions_total +'. Agendar la sesión ' + nextSession + '.');
                  }
                  else
                  {
                    $("#sessions-info").append('<div session_booking_id="' + session_booking.id + '"><input type="radio" name="sessions-choice" value="' + session_booking.id + '">&nbsp;El cliente ha agendado ' + session_booking.sessions_taken + ' de un total de ' + session_booking.sessions_total +'. Agendar la sesión ' + nextSession + '.');
                  }
                  index = index + 1;
                });
              }
            }
          }
        });
      }
    }
    else
    {
      if(parseInt($("#booking_service").val()) > 0)
      {
        $.ajax({
          type: "get",
          url: "/services/" + $("#booking_service").val() + ".json",
          success: function(service)
          {
            console.log(service.name + " has sessions: " + service.has_sessions);
            if(service.has_sessions)
            {
              $("#sessions-info").append('<div session_booking_id="0"><input type="radio" name="sessions-choice" value="0" checked>&nbsp;Este servicio es por sesiones. Generar una nueva reserva y agendar la primera sesión.');
              $("#sessions-row").show();
              $("#add-service-btn").hide();
              $("#has_sessions").val("1");
            }
          }
        });
      }
    }
  }
  else
  {
    if(parseInt($("#booking_service").val()) > 0)
    {
      $.ajax({
        type: "get",
        url: "/services/" + $("#booking_service").val() + ".json",
        success: function(service)
        {
          if(service.has_sessions)
          {
            $("#sessions-info").empty();
            $("#sessions-info").append("Esta reserva corresponde a una sesión de un servicio.");
            $("#sessions-row").show();
          }
          else
          {
            $("#sessions-info").empty();
            $("#sessions-row").hide();
          }
        }
      });
    }
  }
}
