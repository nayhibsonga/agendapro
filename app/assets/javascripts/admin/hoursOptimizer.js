// Auxiliar
var userForm = "#hoursOptimizer #new_booking ";

// Generals
var serviceTitle = "Elegir servicio y staff<br><small>Elige los servicios y prestadores para encontrar el mejor horario para realizarlos</small>";
var serviceButton = "Agregar otro servicio";
var hourTitle = "Resultado de la busqueda<br><small>Selecciona una fecha y hora</small>";
var hourButton = "Ver mas resultados";
var userTitle = "Datos del cliente";
var resultsLength = 6;
var bookings = [];

// Functions
function loadServiceModal () {
  $('#optimizerPrevButton').hide();
  $('#addButton').prop('disabled', true);
  $('#nextButton').prop('disabled', true);
  $('#selectHour').hide();
  $('#hoursOptimizer #new_booking').hide();
  $('#serviceOptimizer').empty();
  $('#serviceOptimizer').show();
  $('#optimizerTitle').html(serviceTitle);
  $('#addButton > span').html(serviceButton);
  loadService();

  $('#addButton').off('click'); // Unbind click event
  $('#addButton').click(function (e) {
    $('#addButton').prop('disabled', true);
    $('#nextButton').prop('disabled', true);
    loadService();
  }); // Bind click event

  $('#nextButton').text('Siguiente');
  $('#nextButton').off('click'); // Unbind click event
  $('#nextButton').click(function (e) {
    loadHourModal();
  }); // Bind click event
}

function loadService () {
  $('#serviceOptimizer').append('<p class="text-center"><i class="fa fa-spinner fa-spin fa-lg"></i></p>');
  var localId = $('#locals-selector').val();
  var admin_origin = true;
  $.getJSON('/local_services', {location: localId, admin_origin: admin_origin}, function (categorized_services) {
    var selectData = '';
    $.each(categorized_services, function (key, service_hash) {
      var category = service_hash.category;
      var services = '';
      $.each(service_hash.services, function (key, service) {
        services += '<option value="' + service.id + '">' + service.name + '</option>';
      });
      selectData += '<optgroup label="' + category + '">' + services + '</optgroup>';
    });

    $('#serviceOptimizer').append(
      '<div class="form-group">' +
        '<label for="serviceOptimizerSelector" class="col-xs-2 control-label">Servicio</label>' +
        '<div class="col-xs-10">' +
          '<select class="form-control" name="serviceOptimizerSelector">' +
            selectData +
          '</select>' +
        '</div>' +
        '<label for="providerOptimizerSelector" class="col-xs-2 control-label">Prestador</label>' +
        '<div class="col-xs-10">' +
          '<select class="form-control" name="providerOptimizerSelector"></select>' +
        '</div>' +
      '</div>'
    );

    $('select[name="serviceOptimizerSelector"]:last').change(function (e) {
      loadStaff(this);
    });

    loadStaff('select[name="serviceOptimizerSelector"]:last');

    $('#serviceOptimizer > p').remove();
  }).always(function () {
    $('#addButton').prop('disabled', false);
    $('#nextButton').prop('disabled', false);
    $('#serviceOptimizer').animate({"scrollTop": $('#serviceOptimizer')[0].scrollHeight}, "slow");
  });
}

function loadStaff (selector) {
  var serviceId = $(selector).val();
  var localId = $('#locals-selector').val();
  var providerPreference = $('#providerPreference').data('provider-preference');
  var admin_origin = true;

  var providerSelector = $(selector).closest('.form-group').find('select[name="providerOptimizerSelector"]');
  $.getJSON('/providers_services', {id: serviceId, local: localId, admin_origin: admin_origin}, function (providers) {
    providerSelector.attr('disabled', true);
    providerSelector.empty();

    if (providerPreference != 1) {
      if (providers.length > 1) {
        providerSelector.append(
          '<option value="0">Sin Preferencia</option>'
        );
      }
    }
    if (providerPreference != 2) {
      $.each(providers, function (key, provider) {
        providerSelector.append(
          '<option value="' + provider.id + '">' + provider.public_name + '</option>'
        );
      });
    }

    providerSelector.attr('disabled', false);
  });
}

function loadHourModal () {
  $('#serviceOptimizer').hide();
  $('#selectHour').empty();
  $('#selectHour').show();
  $('#optimizerTitle').html(hourTitle);
  $('#addButton > span').html(hourButton);

  $('#addButton').prop('disabled', true);
  loadHours();

  $('#addButton').off('click'); // Unbind click event
  $('#addButton').click(function (e) {
    $('#addButton').prop('disabled', true);
    resultsLength += 6;
    $('#selectHour').empty();
    $('#hoursDetails').empty();
    loadHours();
  }); // Bind click event

  $('#nextButton').off('click'); // Unbind click event
  $('#nextButton').click(function (e) {
    if ($('input[name="hoursRadio"]:checked').val()) {
      loadUserModal();
    } else {
      swal('Debe seleccionar una hora');
    };
  }); // Bind click event
}

function loadHours () {
  $('#selectHour').append('<p class="text-center"><i class="fa fa-spinner fa-spin fa-lg"></i></p>');
  var localId = $('#locals-selector').val();
  var selects = [];
  $('select[name="serviceOptimizerSelector"]').each(function (i, service) {
    var provider = $(service).closest('.form-group').find('select[name="providerOptimizerSelector"]');
    selects.push({
      service: $(service).val(),
      provider: provider.val()
    });
  });

  var start_date = $("#optimizerDateSelector").val();

  bookings = [];

  $.getJSON('/optimizer_hours', { local: localId, serviceStaff: JSON.stringify(selects), resultsLength: resultsLength, start_date: start_date, admin: true }, function (hours_array) {
    $('#selectHour > p').remove();
    var services_str = "";
    $.each(hours_array, function (pos, hour) {
      services_str = services_str + '<div class="optimizerDetail" pos="'+ pos +'" hidden><h3>Detalle</h3><br />';
      for(i = 0; i < hour.bookings.length; i++) {
        services_str = services_str + '<label class="checkbox-inline"><p><i class="fa fa-check-circle-o fa-green"></i> ' + hour.bookings[i].service_name +
            '<br />' +
            '<i class="fa fa-calendar-o fa-green"></i> ' + hour.bookings[i].start.split("T")[1].split("+")[0].split(":")[0] + ":" + hour.bookings[i].start.split("T")[1].split("+")[0].split(":")[1] + ' - ' + hour.bookings[i].end.split("T")[1].split("+")[0].split(":")[0] + ":" + hour.bookings[i].end.split("T")[1].split("+")[0].split(":")[1] +
            '<br />' +
            '<i class="fa fa-user fa-green"></i> ' + hour.bookings[i].provider_name +
            '</p></label>';
      }
      services_str = services_str + "</div>";

      $('#selectHour').append(
        '<label class="checkbox-inline">' +
          '<input type="radio" name="hoursRadio" value="' + pos + '">' +
          '<p>' +
            '<i class="fa fa-calendar-o fa-green"></i> ' + hour.date +
            '<br>' +
            '<i class="fa fa-clock-o fa-green"></i> ' + hour.hour +
          '</p>' +
        '</label>'
      );
      bookings.push(hour.bookings);
    });
    if (hours_array.length == 0) {
      $('#selectHour').append('<p class="text-center">No encontramos horarios disponibles</p>');
    }
    else {
      $("#pickerSelectDate").hide();
      $('#hoursDetails').append(services_str);
      $('input[type=radio][name="hoursRadio"]').change(function(e){
        // e.preventDefault();
        $('#hoursDetails').show();
        var pos_num = $(this).val();
        $('.optimizerDetail').each(function(){
          if($(this).attr("pos") != pos_num)
          {
            $(this).hide();
          }
        });
        $('.optimizerDetail[pos="'+pos_num+'"]').toggle();
      });
    }
  }).always(function () {
    $('#addButton').prop('disabled', false);
    $('#selectHour').animate({"scrollTop": $('#selectHour')[0].scrollHeight}, "slow");
    $('#optimizerPrevButton').show();
  });
}

function loadUserModal () {
  $("#hoursDetails").empty();
  $('#selectHour').hide();
  $('#hoursDetails').hide();
  $('#addButton').hide();
  $('#hoursOptimizer #new_booking').show();
  $('#optimizerTitle').html(userTitle);

  $(userForm + '#booking_notes').val($('#calendar-data').data('preset-notes'));

  $('#nextButton').text('Reservar');
  $('#nextButton').off('click'); // Unbind click event
  $('#nextButton').click(function (e) {
    if ($('#hoursOptimizer #new_booking').valid()) {
      $('#nextButton').attr("disabled", "disabled");
      $( '<span id="small_loader"><i class="fa fa-spinner fa-spin"></i> </span>' ).insertBefore( $( "#nextButton" ) );
      loadBookingBuffer();
      saveBookings();
    };
  }); // Bind click event
}

function fullName() {
  if ($(userForm + '#full_name').val() == '') {
    $(userForm + '#xButton').prop('disabled', true);
  }
  else {
    $(userForm + '#xButton').prop('disabled', false);
    var nameArray = $(userForm + '#full_name').val().split(' ');
    if (nameArray.length == 0) {

    }
    else if (nameArray.length == 1) {
      $(userForm + '#booking_client_first_name').val(nameArray[0]);
    }
    else if (nameArray.length == 2) {
      $(userForm + '#booking_client_first_name').val(nameArray[0]);
      $(userForm + '#booking_client_last_name').val(nameArray[1]);
    }
    else if (nameArray.length == 3) {
      $(userForm + '#booking_client_first_name').val(nameArray[0]);
      $(userForm + '#booking_client_last_name').val(nameArray[1]+' '+nameArray[2]);
    }
    else {
      $(userForm + '#booking_client_first_name').val(nameArray[0]+' '+nameArray[1]);
      var last_name = '';
      for (var i = 2; i < nameArray.length; i++) {
        last_name += nameArray[i]+' ';
      }
      var strLen = last_name.length;
      last_name = last_name.slice(0,strLen-1)
      $(userForm + '#booking_client_last_name').val(last_name);
    }
  }
}

function setSuggestionData (client) {
  $(userForm + '#booking_client_first_name').val(client.first_name);
  $(userForm + '#booking_client_last_name').val(client.last_name);
  $(userForm + '#booking_client_phone').val(client.phone);
  $(userForm + '#booking_client_email').val(client.email);
  $(userForm + '#booking_client_id').val(client.id);
  $(userForm + '#booking_client_identification_number').val(client.identification_number);
  $(userForm + '#booking_client_address').val(client.address);
  $(userForm + '#booking_client_district').val(client.district);
  $(userForm + '#booking_client_city').val(client.city);
  $(userForm + '#booking_client_birth_day').val(client.birth_day);
  $(userForm + '#booking_client_birth_month').val(client.birth_month);
  $(userForm + '#booking_client_birth_year').val(client.birth_year);
  $(userForm + '#booking_client_age').val(client.age);
  $(userForm + '#booking_client_gender').val(client.gender);
  $(userForm + "#full_name").val(client.first_name + ' ' + client.last_name);
  $(userForm + '#xButton').prop('disabled', false);
  $(userForm + "#full_name").prop('disabled', true);
  checkEmail();
}

function checkEmail () {
  var email = $(userForm + '#booking_send_mail');
  if ( validEmail( $( userForm + '#booking_client_email').val() ) ) {
    email.attr('disabled', false);
    email.val(1);
    email.attr('checked', true);
  }
  else {
    email.val(0);
    email.attr('checked', false);
    email.attr('disabled', true);
  }
}

function resetForm () {
  $(userForm + '#booking_client_first_name').val('');
  $(userForm + '#booking_client_last_name').val('');
  $(userForm + '#booking_client_phone').val('');
  $(userForm + '#booking_client_email').val('');
  $(userForm + '#booking_client_id').val('');
  $(userForm + '#booking_client_identification_number').val('');
  $(userForm + '#booking_client_address').val('');
  $(userForm + '#booking_client_district').val('');
  $(userForm + '#booking_client_city').val('');
  $(userForm + '#booking_client_birth_day').val('');;
  $(userForm + '#booking_client_birth_month').val('');;
  $(userForm + '#booking_client_birth_year').val('');;
  $(userForm + '#booking_client_age').val('');
  $(userForm + '#booking_client_gender').val('');;
  $(userForm + "#full_name").val('');
  $(userForm + "#full_name").prop('disabled', false);
  $(userForm + '#booking_send_mail').val(0);
  $(userForm + '#booking_send_mail').prop('checked', false);
  $(userForm + '#booking_send_mail').prop('disabled', true);
  $(userForm + '#xButton').prop('disabled', true);
  $(userForm + '#booking_notes').val();
  $(userForm + '#booking_company_comment').val();
  $(userForm + '#booking_staff_code').val();
}

function loadBookingBuffer () {
  bookingBuffer = [];
  var pos = $('input[name="hoursRadio"]:checked').val();
  $.each(bookings[pos], function (pos, booking) {
    bookingBuffer.push({
      client_address: $(userForm + '#booking_client_address').val(),
      client_age: $(userForm + '#booking_client_age').val(),
      client_birth_day: $(userForm + '#booking_client_birth_day').val(),
      client_birth_month: $(userForm + '#booking_client_birth_month').val(),
      client_birth_year: $(userForm + '#booking_client_birth_year').val(),
      client_city: $(userForm + '#booking_client_city').val(),
      client_district: $(userForm + '#booking_client_district').val(),
      client_email: $(userForm + '#booking_client_email').val(),
      client_first_name: $(userForm + '#booking_client_first_name').val(),
      client_gender: $(userForm + '#booking_client_gender').val(),
      client_id: $(userForm + '#booking_client_id').val(),
      client_identification_number: $(userForm + '#booking_client_identification_number').val(),
      client_last_name: $(userForm + '#booking_client_last_name').val(),
      client_phone: $(userForm + '#booking_client_phone').val(),
      company_comment: $(userForm + '#booking_company_comment').val(),
      end: booking.end,
      notes: $(userForm + '#booking_notes').val(),
      price: booking.price,
      provider_lock: booking.provider_lock,
      send_mail: $(userForm + '#booking_send_mail').prop('checked'),
      service_id: booking.service,
      service_provider_id: booking.provider,
      staff_code: $(userForm + '#booking_staff_code').val(),
      start: booking.start,
      status_id: $(userForm + '#booking_status_id').val()
    });
  });
}

function saveBookings () {
  $.ajax({
    type: 'POST',
    url: '/bookings.json',
    data: { "bookings": bookingBuffer },
    dataType: 'json',
    success: function(bookings){
      $('#bookingAlerts').hide();
      $('#bookingWarnings').empty();
      var warning = false;
      $.each(bookings, function (pos, booking) {
        if (booking.status_id != 5) {
          var providerLock = '-unlock';
          if (booking.provider_lock) {
            providerLock = '-lock';
          };
          var originClass = 'origin-manual';
          originClass += providerLock + statusIcon[booking.status_id];
          var events = {
            id: booking.id,
            title: booking.first_name+' '+booking.last_name+' - '+booking.service_name,
            allDay: false,
            start: booking.start,
            end: booking.end,
            resourceId: booking.service_provider_id,
            className: originClass,
            title_qtip: booking.first_name+' '+booking.last_name,
            time_qtip: booking.start.substring(11,16) + ' - ' + booking.end.substring(11,16),
            service_qtip: booking.service_name,
            phone_qtip: booking.phone,
            email_qtip: booking.email,
            comment_qtip: booking.company_comment
          };
          $('#calendar').fullCalendar('renderEvent', events, true);
        }
        if (booking.warnings.length > 0) {
          var warnings = '';
          for (i in booking.warnings) {
            warnings += booking.warnings[i] + '. ';
          }
          $('#bookingWarnings').append(warnings);
          warning = true;
        }
      });
      if (warning) {
        $('#bookingAlerts').show();
      };
      $('#hoursOptimizer').modal('hide');
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors;
      var errores = '';
      $.each(errors, function (booking, error) {
        errores += 'Servicio ' + error.booking + '\n';
        for (i in error.errors) {
          errores += ' * ' + error.errors[i] + '\n';
        }
      });
      errores += '\n¿Guardar de todos modos?';
      $('#nextButton').removeAttr("disabled");
      $('#small_loader').remove();
      swal({
        title: "No se pudo guardar todos los servicios",
        text: errores,
        type: "warning"
      },
      function (isConfirm) {
        if (isConfirm) {
          $.post('/force_create.json', { "bookings": bookingBuffer }, function (bookings) {
            $('#bookingAlerts').hide();
            $('#bookingWarnings').empty();
            var warning = false;
            $.each(bookings, function (pos, booking) {
              if (booking.status_id != 5) {
                var providerLock = '-unlock';
                if (booking.provider_lock) {
                  providerLock = '-lock';
                };
                var originClass = 'origin-manual';
                originClass += providerLock + statusIcon[booking.status_id];
                var events = {
                  id: booking.id,
                  title: booking.first_name+' '+booking.last_name+' - '+booking.service_name,
                  allDay: false,
                  start: booking.start,
                  end: booking.end,
                  resourceId: booking.service_provider_id,
                  className: originClass,
                  title_qtip: booking.first_name+' '+booking.last_name,
                  time_qtip: booking.start.substring(11,16) + ' - ' + booking.end.substring(11,16),
                  service_qtip: booking.service_name,
                  phone_qtip: booking.phone,
                  email_qtip: booking.email,
                  comment_qtip: booking.company_comment
                };
                $('#calendar').fullCalendar('renderEvent', events, true);
              }
              if (booking.warnings.length > 0) {
                var warnings = '';
                for (i in booking.warnings) {
                  warnings += booking.warnings[i] + '. ';
                }
                $('#bookingWarnings').append(warnings);
                warning = true;
              }
            });
            if (warning) {
              $('#bookingAlerts').show();
            };
            $('#hoursOptimizer').modal('hide');
          });
        } else{
          $('#hoursOptimizer').modal('hide');
        };
      });
    }
  });
}

$(function () {
  $('#hoursOptimizer').on('show.bs.modal', function (e) {
    $('#bookingModal').modal('hide');
    $('#addButton').show();
    resultsLength = 6;
    bookings = [];
    resetForm();
    loadServiceModal();
  });

  $('#optimizerPrevButton').click(function(e){
    resultsLength = 6;
    bookings = [];
    resetForm();
    loadServiceModal();
    $('#addButton').show();
    $("#hoursDetails").empty();
    $("#pickerSelectDate").show();
  });

  $('#hoursOptimizer').on('hidden.bs.modal', function (e) {
    optimizerValidator.resetForm();
    $("#pickerSelected").empty();
    $("#pickerSelected").append($("#initialPickerDate").val());
    $("#pickerSelectDate").show();
    $("#hoursDetails").empty();
    $('#addButton').show();
    $('.has-success').removeClass('has-success');
    $('.fa.fa-check').removeClass('fa fa-check');
    $('.has-error').removeClass('has-error');
    $('#hoursOptimizer #new_booking').find('.fa.fa-times').removeClass('fa fa-times');
    $('#nextButton').removeAttr("disabled");
    $('#small_loader').remove();
  });

  $('body').on('click', '.optimizerDetailLink', function(e){
    console.log("Clicked");
    e.preventDefault();
    var pos_num = $(this).attr('pos');
    $('#hoursDetails').show();
    $('.optimizerDetail[pos="'+pos_num+'"]').show();
  });

  $(userForm + "#full_name").on('input',function(e){
    fullName();
  });

  $(userForm + "#full_name").autocomplete({
    source: '/clients_name_suggestion',
    appendTo: '#hoursOptimizer #new_booking #full_name_suggestions',
    autoFocus: true,
    minLength: 3,
    select: function( event, ui ) {
      event.preventDefault();
      var client = eval("(" + ui.item.value + ")");
      setSuggestionData(client);
      checkEmail();
    }
  }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    return $( '<li>' ).append( '<a>' + item.label + '<br><span class="auto-desc">' + item.desc + '</span></a>' ).appendTo( ul );
  };

  $(userForm + "#booking_client_email").autocomplete({
    source: '/clients_suggestion',
    appendTo: '#hoursOptimizer #new_booking #email_suggestions',
    autoFocus: true,
    minLength: 3,
    select: function( event, ui ) {
      event.preventDefault();
      var client = eval("(" + ui.item.value + ")");
      setSuggestionData(client);
      checkEmail();
    }
  }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    return $( '<li>' ).append( '<a>' + item.label + '<br><span class="auto-desc">' + item.desc + '</span></a>' ).appendTo( ul );
  };

  $(userForm + "#booking_client_identification_number").autocomplete({
    source: '/clients_rut_suggestion',
    appendTo: '#hoursOptimizer #new_booking #rut_suggestions',
    autoFocus: true,
    minLength: 3,
    select: function( event, ui ) {
      event.preventDefault();
      var client = eval("(" + ui.item.value + ")");
      setSuggestionData(client);
      checkEmail();
    }
  }).data( "ui-autocomplete" )._renderItem = function( ul, item ) {
    return $( '<li>' ).append( '<a>' + item.label + '<br><span class="auto-desc">' + item.desc + '</span></a>' ).appendTo( ul );
  };

  $(userForm + "#booking_client_email").on('input',function(e){
    checkEmail();
  });

  $(userForm + '#xButton').click(function() {
    resetForm();
  });

  $("#optimizerDateSelector").datepicker({
    dateFormat: 'dd/mm/yy',
    autoSize: true,
    firstDay: 1,
    changeMonth: true,
    changeYear: true,
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    prevText: 'Atrás',
    nextText: 'Adelante',
    dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    dayNamesMin: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    today: 'Hoy',
    clear: '',
    onSelect: function(newDate){
      $("#pickerSelected").empty();
      $("#pickerSelected").append(newDate);
    },
    beforeShow: function(date) {
      $('#ui-datepicker-div').addClass("customDatepicker");
      $(".customDatepicker .ui-datepicker-calendar").css("width", "214px !important");
    }
  });

  $(document.body).on('click', '.optimizer-date-span', function(e){
    $(e.currentTarget).find('input').datepicker('show');
  });
});
