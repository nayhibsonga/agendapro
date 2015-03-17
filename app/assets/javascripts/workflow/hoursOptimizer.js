// Generals
var serviceTitle = "Elegir servicio y staff<br><small>Elige los servicios y prestadores para encontrar el mejor horario para realizarlos</small>";
var serviceButton = "Agregar otro servicio";
var hourTitle = "Resultado de la búsqueda<br><small>Selecciona una fecha y hora</small>";
var hourButton = "Ver mas resultados";
var resultsLength = 6;
var bookings = []

// Functions
function loadServiceModal () {
  $('#addButton').prop('disabled', true);
  $('#nextButton').prop('disabled', true);
  $('#selectHour').hide();
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

  $('#nextButton').off('click'); // Unbind click event
  $('#nextButton').click(function (e) {
    loadHourModal();
  }); // Bind click event
}

function loadService () {
  $('#serviceOptimizer').append('<p class="text-center"><i class="fa fa-spinner fa-spin fa-lg"></i></p>');
  var localId = $('#selectedLocal').data('local').id;
  $.getJSON('/local_services', {location: localId}, function (categorized_services) {
    var selectData = '';
    $.each(categorized_services, function (key, service_hash) {
      var category = service_hash.category;
      var services = '';
      $.each(service_hash.services, function (key, service) {
        services += '<option value="' + service.id + '">' + service.name + '</option>';
      });
      selectData += '<optgroup label="' + category + '">' + services + '</optgroup>';
    });

    //Load date picker.

    //Load service/provider picker.
    $('#serviceOptimizer').append(
      '<div class="form-group">' +
        '<label for="serviceOptimizerSelector" class="col-xs-3 control-label">Servicio</label>' +
        '<div class="col-xs-9" style="margin-bottom: 10px !important;">' +
          '<select class="form-control" name="serviceOptimizerSelector">' +
            selectData +
          '</select>' +
        '</div>' +
        '<label for="providerOptimizerSelector" class="col-xs-3 control-label">Prestador</label>' +
        '<div class="col-xs-9">' +
          '<select class="form-control" name="providerOptimizerSelector"></select>' +
        '</div>' +
      '</div>'
    );

    loadStaff('select[name="serviceOptimizerSelector"]:last');
    $('select[name="serviceOptimizerSelector"]:last').change(function (e) {
      loadStaff(this);
    });

    $('#serviceOptimizer > p').remove();
  }).always(function () {
    $('#addButton').prop('disabled', false);
    $('#nextButton').prop('disabled', false);
  });

}

function loadStaff (selector) {
  var serviceId = $(selector).val();
  var localId = $('#selectedLocal').data('local').id;
  var providerPreference = $('#providerPreference').data('provider-preference');

  var providerSelector = $(selector).closest('.form-group').find('select[name="providerOptimizerSelector"]');
  $.getJSON('/providers_services', {id: serviceId, local: localId}, function (providers) {
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
    loadHours();
  }); // Bind click event

  $('#nextButton').off('click'); // Unbind click event
  $('#nextButton').click(function (e) {
    if ($('input[name="hoursRadio"]:checked').val()) {
      userData();
    } else {
      alert('Debe seleccionar una hora');
    };
  }); // Bind click event
}

function loadHours () {
  $('#selectHour').append('<p class="text-center"><i class="fa fa-spinner fa-spin fa-lg"></i></p>');
  var localId = $('#selectedLocal').data('local').id;
  var selects = [];
  $('select[name="serviceOptimizerSelector"]').each(function (i, service) {
    var provider = $(service).closest('.form-group').find('select[name="providerOptimizerSelector"]');
    selects.push({
      service: $(service).val(),
      provider: provider.val()
    });
  });

  var start_date = $("#optimizerDateSelector").val();

  $.getJSON('/optimizer_hours', { local: localId, serviceStaff: JSON.stringify(selects), resultsLength: resultsLength, start_date: start_date }, function (hours_array) {
    $('#selectHour > p').remove();
    var services_str = "";
    $.each(hours_array, function (pos, hour) {
      console.log(hour.bookings);
      services_str = services_str + '<div class="optimizerDetail" pos="'+ pos +'" hidden><h3>Detalle</h3><br />';
      for(i = 0; i < hour.bookings.length; i++)
      {
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
            '<br />' +
            '<i class="fa fa-clock-o fa-green"></i> ' + hour.hour +
            '<br /><a href="#" class="optimizerDetailLink" pos="'+ pos +'">Ver detalle</a>' +
          '</p>' +
        '</label>'
      );
      bookings.push(hour.bookings);
    });
    if (hours_array.length == 0) {
      $('#selectHour').append('<p class="text-center">No encontramos horarios disponibles</p>');
    }
    else
    {
      $("#pickerSelectDate").hide();
      $('#hoursDetails').append(services_str);
      $('.optimizerDetailLink').on('click', function(e){
        e.preventDefault();
        var pos_num = $(this).attr('pos');
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
  });
}

function userData () {
  var pos = $('input[name="hoursRadio"]:checked').val();
  $('#userData > .bookings').val(JSON.stringify(bookings[pos]));
  $('#userData').submit();
}

$(function () {
  $('#hoursOptimizer').on('show.bs.modal', function (e) {
    resultsLength = 6;
    bookings = [];
    loadServiceModal();
  });

  $('#hoursOptimizer').on('hide.bs.modal', function(e){
    $("#hoursDetails").empty();
    $("#pickerSelected").empty();
    //var prettyDate = newDate.split("-")[2] + "/" + newDate.split("-")[1] + "/" + newDate.split("-")[0];
    $("#pickerSelected").append($("#initialPickerDate").val());
    $("#pickerSelectDate").show();
  });

  $('.optimizerDetailLink').on('click', function(e){
    e.preventDefault();
    var pos_num = $(this).attr('pos');
    $('.optimizerDetail[pos="'+pos_num+'"]').show();
  });

});


