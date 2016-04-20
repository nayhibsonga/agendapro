var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var hoursChanged = false;

function buildDay (value) {
  $('#localTable').append(
    '<tr>' +
      '<td>' +
        '<div class="checkbox">' +
          '<label>' +
            '<input type="checkbox" name="dayStatus'+ value +'" id="dayStatusId'+ value +'" value="0" onchange="changeDayStatus('+ value +')"> ' + days[value - 1] + ':' +
          '</label>' +
        '</div>' +
      '</td>' +
      '<td>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control" id="openHourId'+ value +'" name="openHour'+ value +'" disabled="disabled">' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
              '<option value="04">04</option>' +
              '<option value="05">05</option>' +
              '<option value="06">06</option>' +
              '<option value="07">07</option>' +
              '<option value="08">08</option>' +
              '<option value="09" selected>09</option>' +
              '<option value="10">10</option>' +
              '<option value="11">11</option>' +
              '<option value="12">12</option>' +
              '<option value="13">13</option>' +
              '<option value="14">14</option>' +
              '<option value="15">15</option>' +
              '<option value="16">16</option>' +
              '<option value="17">17</option>' +
              '<option value="18">18</option>' +
              '<option value="19">19</option>' +
              '<option value="20">20</option>' +
              '<option value="21">21</option>' +
              '<option value="22">22</option>' +
              '<option value="23">23</option>' +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control" id="openMinuteId'+ value +'" name="openMinute'+ value +'" disabled="disabled">' +
              '<option value="00" selected>00</option>' +
              '<option value="15">15</option>' +
              '<option value="30">30</option>' +
              '<option value="45">45</option>' +
            '</select>' +
          '</div>' +
        '</form>' +
      '</td>' +
      '<td>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control" id="closeHourId'+ value +'" name="closeHour'+ value +'" disabled="disabled">' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
              '<option value="04">04</option>' +
              '<option value="05">05</option>' +
              '<option value="06">06</option>' +
              '<option value="07">07</option>' +
              '<option value="08">08</option>' +
              '<option value="09">09</option>' +
              '<option value="10">10</option>' +
              '<option value="11">11</option>' +
              '<option value="12">12</option>' +
              '<option value="13">13</option>' +
              '<option value="14">14</option>' +
              '<option value="15">15</option>' +
              '<option value="16">16</option>' +
              '<option value="17">17</option>' +
              '<option value="18" selected>18</option>' +
              '<option value="19">19</option>' +
              '<option value="20">20</option>' +
              '<option value="21">21</option>' +
              '<option value="22">22</option>' +
              '<option value="23">23</option>' +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control" id="closeMinuteId'+ value +'" name="closeMinute'+ value +'" disabled="disabled">' +
              '<option value="00" selected>00</option>' +
              '<option value="15">15</option>' +
              '<option value="30">30</option>' +
              '<option value="45">45</option>' +
            '</select>' +
          '</div>' +
        '</form>' +
      '</td>' +
    '</tr>'
  );
}

function initialize() {
  for(var i = 1; i < 8; ++i) {
    buildDay(i);
  }

  if ( $('#title').length > 0 ) {
    var locationTimesData = $('#location_times_data').data('location-times');
    $.each(locationTimesData, function(index,locationTime) {
      var value = locationTime.day_id;
      $('#dayStatusId'+ value).prop('checked', true);
      $('#dayStatusId'+ value).val(1);

      $('#openHourId'+ value).prop('disabled', false);
      $('#openMinuteId'+ value).prop('disabled', false);
      $('#closeHourId'+ value).prop('disabled', false);
      $('#closeMinuteId'+ value).prop('disabled', false);
      // Deseleccionar por defecto
      $('#openHourId' + value + ' > option:selected').removeAttr('selected');
      $('#openMinuteId' + value + ' > option:selected').removeAttr('selected');
      $('#closeHourId' + value + ' > option:selected').removeAttr('selected');
      $('#closeMinuteId' + value + ' > option:selected').removeAttr('selected');

      var openTime = new Date(Date.parse(locationTime.open)).toUTCString().split(" ")[4].split(":");
      var closeTime = new Date(Date.parse(locationTime.close)).toUTCString().split(" ")[4].split(":");

      $('#openHourId'+ value +' option[value="'+openTime[0]+'"]').attr("selected",true);
      $('#openMinuteId'+ value +' option[value="'+openTime[1]+'"]').attr("selected",true);
      $('#closeHourId'+ value +' option[value="'+closeTime[0]+'"]').attr("selected",true);
      $('#closeMinuteId'+ value +' option[value="'+closeTime[1]+'"]').attr("selected",true);
    });
    if ($('#location_outcall').prop('checked')) {
      $('#location_outcall_places').closest(".form-group").toggle();
    }
    var latitude = parseFloat($('#location_latitude').val());
    var longitude = parseFloat($('#location_longitude').val());
    setCenter(new google.maps.LatLng(latitude, longitude), 17);
  }
  else {
    $('#saveLocation').attr('disabled', true);
    for (var i = 0; i < 6; i++) {
      changeDayStatus(i);
      $('#dayStatusId' + i).prop('checked', true).val(1);
    };
  };

  $('#localTable').on('change', function() {
    hoursChanged = true;
  });
}

function changeDayStatus (value) {
  if ($('#dayStatusId'+ value).val() == 0) {
    $('#openHourId'+ value).prop('disabled', false);
    $('#openMinuteId'+ value).prop('disabled', false);
    $('#closeHourId'+ value).prop('disabled', false);
    $('#closeMinuteId'+ value).prop('disabled', false);
    $('#dayStatusId'+ value).val(1);
  }
  else if ($('#dayStatusId'+ value).val() == 1) {
    $('#openHourId'+ value).prop('disabled', true);
    $('#openMinuteId'+ value).prop('disabled', true);
    $('#closeHourId'+ value).prop('disabled', true);
    $('#closeMinuteId'+ value).prop('disabled', true);
    $('#dayStatusId'+ value).val(0);
  }
}

function locJSON() {
  var enabledDays = [];
  for(var i = 1; i < 8; ++i) {
    if ($('#dayStatusId'+ i).val() == 1) {
      enabledDays.push($('#dayStatusId'+ i).attr('id').slice(-1));
    }
  }
  var location_times = [];
  for (i in enabledDays) {
    var location_time = {"open":"2000-01-01T"+ $('#openHourId'+enabledDays[i]).val() +":"+ $('#openMinuteId'+enabledDays[i]).val() +":00Z","close":"2000-01-01T"+ $('#closeHourId'+enabledDays[i]).val() +":"+ $('#closeMinuteId'+enabledDays[i]).val() +":00Z","day_id":parseInt(enabledDays[i])};
    location_times.push(location_time);
  }
  var locationJSON  = {
    "name": $('#location_name').val(),
    "country_id": $('#location_country_id').val(),
    "address": $('#location_address').val(),
    "second_address": $('#location_second_address').val(),
    "phone": $('#location_phone').val(),
    "outcall": $('#location_outcall').prop('checked'),
    "outcall_places": $('#location_outcall_places').val(),
    "latitude": parseFloat($('#location_latitude').val()),
    "longitude": parseFloat($('#location_longitude').val()),
    "location_times_attributes": location_times,
    "company_id": $('#location_company_id').val(),
    "email": $('#location_email').val(),
    "online_booking": $('#location_online_booking').prop('checked')
  };
  return locationJSON;
}

function saveLocation() {
  var locationJSON = locJSON();
  var defaults = {
    data: { location: locationJSON },
    dataType: 'json',
    success: function(location){
      if (location.warnings != null && location.warnings.length > 0) {
        swal({
          title: "¡Completado!",
          text: location.warnings,
          type: "success"
        }, function() {
          document.location.href = '/locations/';
        });
      } else {
        document.location.href = '/locations/';
      };
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors;
      var errorList = '';
      for (i in errors) {
        errorList += '- ' + errors[i] + '\n\n';
      }
      swal({
        title: "Error",
        text: "Se produjeron los siguientes errores:\n\n" + errorList,
        type: "error"
      });
    }
  };

  if ( $('#title').length > 0 ) {
    var locationId = $('#id_data').data('id');
    var option = {
      type: "PATCH",
      url: '/locations/'+ JSON.stringify(locationId) +'.json'
    };
  }
  else {
    var option = {
      type: "POST",
      url: '/locations.json'
    };
  };
  var options = $.extend({}, defaults, option);

  if( hoursChanged ) {
    swal({
      title: "Advertencia",
      text: "Los horarios del Staff se ajustarán automáticamente,    ¿Seguro que desea continuar?",
      type: "warning",
      showCancelButton: true,
      showLoaderOnConfirm: true
    }, function() {
      setTimeout($.ajax(options), 1500);
    });
  } else {
    $.ajax(options);
  }
}

/*** Google Maps ***/
var map;
var marker;
function createMap () {
  var mapProp = {
    center: new google.maps.LatLng(-33.413673, -70.573426),
    zoom: 15,
    mapTypeId: google.maps.MapTypeId.ROADMAP
  };
  map = new google.maps.Map(document.getElementById('map'), mapProp);

  google.maps.event.addListener(map, 'click', function (event) {
    var latLng = event.latLng;
    setCenter(latLng, 17);
  });
}

function setMarker (latLng) {
  marker = new google.maps.Marker({
    position: latLng,
    map: map
  });
}

function setCenter (latLng, zoom) {
  zoom = typeof zoom != "undefined" ? zoom : 17;
  if (marker) {
    marker.setMap(null);
  };
  map.panTo(latLng);
  map.setCenter(latLng);
  map.setZoom(zoom);
  setMarker(latLng);
}

/*** Google Places ***/
function places() {
  var input = document.getElementById('address');
  var options = {
    types: ['geocode']
  };
  var geocoder = new google.maps.Geocoder();
  var autocomplete = new google.maps.places.Autocomplete(input, options);
  var infowindow = new google.maps.InfoWindow();

  google.maps.event.addListener(autocomplete, 'place_changed', function() {
    if (autocomplete.getPlace().geometry) {
      setLatLng(autocomplete.getPlace().geometry.location);
      setAddress(autocomplete.getPlace());
      setCenter(autocomplete.getPlace().geometry.location);
    } else {
      $('#location_address, #location_latitude, #location_longitude').val('');
    };
    $('#address').valid();
  });

  function geolocate() {
    $('#saveLocation').attr('disabled', true);
    if (navigator.geolocation) {
      $('#geolocate').html('<i class="fa fa-spinner fa-spin"></i>');
      var positioned = false;
      navigator.geolocation.getCurrentPosition(
        function(position) {
          positioned = true;
          $('#location_latitude').val(position.coords.latitude);
          $('#location_longitude').val(position.coords.longitude);

          var latlng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
          geocoder.geocode({'latLng': latlng}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
              setAddress(results[0]);
            } else {
              $('#location_address').val('');
              $('#address').val('');
            }
            setCenter(latlng);
            $('#geolocate').html('<i class="fa fa-crosshairs"></i>');
            return false;
          });
        },
        function (error) {
          positioned = true;
          var errorMessage = {
            1: "No hay permiso, por favor asegúrate permitir la geolicalización automática en tu explorador.",
            2: "Posición no disponible, por favor inténtalo nuevamente o escribe tu ubicación.",
            3: "La consulta tardó mucho, por favor inténtalo nuevamente o escribe tu ubicación."
          }[error.code] || "Error desconocido, por favor inténtalo nuevamente o escribe tu ubicación."
          swal({
            title: "Hubo un error en el proceso de localización",
            text: errorMessage,
            type: "error"
          });
          $('#geolocate').html('<i class="fa fa-crosshairs"></i>');
        },
        {timeout: 10000}
      );
      setTimeout(function () {
        if (!positioned) {
          swal({
            title: "Hubo un error en el proceso de localización",
            text: "No hubo respuesta, por favor asegúrate permitir la geolicalización automática en tu explorador.",
            type: "error"
          });
          $('#geolocate').html('<i class="fa fa-crosshairs"></i>');
        }
      }, 15000);
    }
    else {
      swal({
        title: "Hubo un error en el proceso de la localización",
        text: "Este explorador ni permite geolocalización automática, por favor escribe tu ubicación.",
        type: "error"
      });
    }
    return;
  }

  function setLatLng(location) {
    $('#location_latitude').val(location.lat());
    $('#location_longitude').val(location.lng());
  }

  function setAddress(geobject) {
    $("#address").val(geobject.formatted_address);
    $("#location_address").val(JSON.stringify(geobject.address_components));
    $('#saveLocation').attr('disabled', false);
  }

  $('#geolocate').click(function() {
    geolocate();
  });
}

/***    Popover    ***/
function popover() {
  var inputgroup = $('#popover-link');
  var opened = false;
  var close;

  // Generate popover
  inputgroup.popover({
    content: function() {
      return $('#content-popover').removeClass('no-show').detach();
    },
    container: "body",
    title: 'Ubicación de tu Local<span class="close"><i class="fa fa-close"></i></span>',
    placement: function () {
      return $('html').width() > 981 ? 'right' : 'bottom';
    }
  });

  // Bind events
  inputgroup.focusin(function(event) {
    if (!opened) {
      opened = true;
      inputgroup.popover('show');
    };
  });
  inputgroup.on('shown.bs.popover', function() {
    close = $('.popover .close');
    close.click(function(event) {
      inputgroup.popover('hide');
    });
  });
  inputgroup.on('hide.bs.popover', function() {
    $('#map-placement').append($('#content-popover').addClass('no-show').detach());
    opened = false;
    close.unbind('click');
  });
  $('body').click(function(event) {
    var element = event.target;
    var group = element.closest('.input-group');
    var popover = element.closest('.popover');
    var icon = $(element).hasClass('fa-crosshairs');
    if (!group && !popover && !icon) {
      inputgroup.popover('hide');
    };
  });
}

$(function() {
  createMap();
  places();
  initialize();
  popover();

  $('#saveLocation').click(function() {
    saveLocation();
    return false;
  });

  $('#location_outcall').change(function() {
    $('#location_outcall_places').closest(".form-group").toggle();
  });
});
