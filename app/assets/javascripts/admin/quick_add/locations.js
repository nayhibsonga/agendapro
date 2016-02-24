function initializeStep2 () {
	$('#fieldset_step2').removeAttr('disabled');
	createMap();
	places();
	initialize('local');
}

var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var local = 'local';

function buildDay (value, ctrl) {
	$('#' + ctrl + 'Table').append(
		'<tr>' +
			'<td>' +
				'<div class="checkbox">' +
				    '<label>' +
				    	'<input type="checkbox" name="' + ctrl + 'dayStatus'+ value +'" id="' + ctrl + 'dayStatusId'+ value +'" value="0" onchange="changeDayStatus('+ value +',' + ctrl + ')"> ' + days[value - 1] + ':' +
				    '</label>' +
				'</div>' +
			'</td>' +
			'<td>' +
				'<form class="form-inline" role="form">' +
					'<div class="form-group">' +
						'<select class="form-control time-select" id="' + ctrl + 'openHourId'+ value +'" name="' + ctrl + 'openHour'+ value +'" disabled="disabled">' +
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
						'<select class="form-control time-select" id="' + ctrl + 'openMinuteId'+ value +'" name="' + ctrl + 'openMinute'+ value +'" disabled="disabled">' +
							'<option value="00" selected>00</option>' +
							'<option value="15">15</option>' +
							'<option value="30">30</option>' +
							'<option value="45">45</option>' +
						'</select>' +
					'</div>' +
					'<div class="form-group">' +
						'<label>&nbsp;&nbsp;-&nbsp;&nbsp;</label>' +
					'</div>' +
				'</form>' +
			'</td>' +
			'<td>' +
				'<form class="form-inline" role="form">' +
					'<div class="form-group">' +
						'<select class="form-control time-select" id="' + ctrl + 'closeHourId'+ value +'" name="' + ctrl + 'closeHour'+ value +'" disabled="disabled">' +
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
						'<select class="form-control time-select" id="' + ctrl + 'closeMinuteId'+ value +'" name="' + ctrl + 'closeMinute'+ value +'" disabled="disabled">' +
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

function initialize (ctrl) {
	$('#' + ctrl + 'Table').empty();
	for(var i = 1; i < 8; ++i) {
		buildDay(i, ctrl);
	}
}

function changeDayStatus (value, ctrl) {
	if ($('#' + ctrl + 'dayStatusId'+ value).val() == 0) {
		$('#' + ctrl + 'openHourId'+ value).prop('disabled', false);
		$('#' + ctrl + 'openMinuteId'+ value).prop('disabled', false);
		$('#' + ctrl + 'closeHourId'+ value).prop('disabled', false);
		$('#' + ctrl + 'closeMinuteId'+ value).prop('disabled', false);
		$('#' + ctrl + 'dayStatusId'+ value).val(1);
	}
	else if ($('#' + ctrl + 'dayStatusId'+ value).val() == 1) {
		$('#' + ctrl + 'openHourId'+ value).prop('disabled', true);
		$('#' + ctrl + 'openMinuteId'+ value).prop('disabled', true);
		$('#' + ctrl + 'closeHourId'+ value).prop('disabled', true);
		$('#' + ctrl + 'closeMinuteId'+ value).prop('disabled', true);
		$('#' + ctrl + 'dayStatusId'+ value).val(0);
	}
}

function saveLocation (typeURL, extraURL) {
  console.log("saveLocation")
	var locationJSON = locJSON('local');
	$.ajax({
		type: typeURL,
		url: '/quick_add/location'+extraURL+'.json',
		data: { "location": locationJSON },
		dataType: 'json',
		success: function (result){
			$('#load_location_spinner').show();
			$('#location_pills.nav-pills li').removeClass('active');
			if (typeURL == 'POST') {
				swal({
					title: "Local creado exitosamente.",
					type: "success"
				});
				$('#new_location_pill').parent().before('<li><a href="#" id="location_pill_'+result.id+'">'+result.name+'<!--  <button id="location_delete_'+result.id+'" class="btn btn-danger btn-xs"><i class="fa fa-trash-o"></i></button> --></a></li>');
				$('#service_provider_location_id').append('<option value="'+ result.id +'">'+ result.name +'</option>')
				$('#location_pill_'+result.id).click(function(event){
					event.preventDefault();
					$('#load_location_spinner').show();
					$('#location_pills.nav-pills li').removeClass('active');
					load_location(result.id);
				});
			}
			else {
				swal({
					title: "Local modificado exitosamente.",
					type: "success"
				});
				$('#location_pill_'+result.id).html(result.name);
				$('#service_provider_location_id option[value="'+ result.id +'"]').html(result.name);
			}
			$('#update_location_spinner').hide();
			$('#update_location_button').attr('disabled', false);
			$('#next_location_button').attr('disabled', false);
			new_location();
		},
		error: function (xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var location_count = $.parseJSON(xhr.responseText).location_count
			var errorList = '';
			for (i in errors) {
				errorList += '- ' + errors[i] + '\n\n'
			}
			swal({
				title: "Error",
				text: "Se produjeron los siguientes problemas:\n\n" + errorList,
				type: "error",
				html: true
			});
			if (location_count > 0) {
				$('#next_location_button').attr('disabled', false);
			}
			$('#update_location_spinner').hide();
			$('#update_location_button').attr('disabled', false);
		}
	});
}

function locJSON (ctrl) {
	var enabledDays = [];
	for(var i = 1; i < 8; ++i) {
		if ($('#localdayStatusId'+ i).val() == 1) {
			enabledDays.push($('#localdayStatusId'+ i).attr('id').slice(-1));
		}
	}
	var location_times = [];
	for (i in enabledDays) {
		var location_time = {"open":"2000-01-01T"+ $('#' + ctrl + 'openHourId'+enabledDays[i]).val() +":"+ $('#' + ctrl + 'openMinuteId'+enabledDays[i]).val() +":00Z","close":"2000-01-01T"+ $('#' + ctrl + 'closeHourId'+enabledDays[i]).val() +":"+ $('#' + ctrl + 'closeMinuteId'+enabledDays[i]).val() +":00Z","day_id":parseInt(enabledDays[i])};
		location_times.push(location_time);
	}
	var locationJSON  = {
		"name": $('#location_name').val(),
    "country_id": $('#location_country_id').val(),
		"address": $('#location_address').val(),
		"second_address": $('#location_second_address').val(),
		"phone": $('#location_phone').val(),
		"outcall": $('#location_outcall').prop('checked'),
		"outcall_places": $('#location_outcall_places'),
		"latitude": parseFloat($('#location_latitude').val()),
		"longitude": parseFloat($('#location_longitude').val()),
		"location_times_attributes": location_times,
		"email": $("#location_email").val()
	};
	return locationJSON;
}

function new_location() {
	location_validation.resetForm();
	$('#new_location .form-group').removeClass('has-error has-success');
	$('#new_location .form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check');
	$('#location_name,\
		#address,\
		#location_address,\
		#location_second_address,\
		#location_phone,\
		#location_latitude,\
		#location_longitude,\
		#location_outcall_places,\
		#location_email').val('');
	$('#location_outcall').prop('checked', false);
	$('#location_outcall_places').closest(".form-group").hide();
	$('#update_location_button').attr('name', 'new_location_btn');
	$('#new_location_pill').parent().addClass('active');
	$('#load_location_spinner').hide();
	initialize('local');
}

function load_location(id) {
	location_validation.resetForm();
	$('#new_location .form-group').removeClass('has-error has-success');
	$('#new_location .form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check');
	$.getJSON('/quick_add/load_location/'+id, {}, function (location) {
		$('#location_name').val(location.location.name);
		$('#address').val(location.location.full_address);
		$('#location_address').val(location.location.address);
		$('#location_second_address').val(location.location.second_address);
		$('#location_phone').val(location.location.phone);
		$('#location_outcall').prop('checked', location.location.outcall);
		$('#location_outcall_places').val(location.location.outcall_places);
		$('#location_latitude').val(location.location.latitude);
		$('#location_longitude').val(location.location.longitude);
		$('#location_email').val(location.location.email);
		var latitude = parseFloat($('#location_latitude').val());
		var longitude = parseFloat($('#location_longitude').val());
		setCenter(new google.maps.LatLng(latitude, longitude), 17);
		$('select.time-select').attr('disabled', true);
		$('#localTable input:checkbox').prop('checked', false);
		$.each(location.location_times, function(index,locationTime) {
			var value = locationTime.day_id;
			$('#localdayStatusId'+ value).prop('checked', true);
			$('#localdayStatusId'+ value).val(1);

			$('#localopenHourId'+ value).prop('disabled', false);
			$('#localopenMinuteId'+ value).prop('disabled', false);
			$('#localcloseHourId'+ value).prop('disabled', false);
			$('#localcloseMinuteId'+ value).prop('disabled', false);
			// Deseleccionar por defecto
			$('#localopenHourId' + value + ' > option:selected').removeAttr('selected');
			$('#localopenMinuteId' + value + ' > option:selected').removeAttr('selected');
			$('#localcloseHourId' + value + ' > option:selected').removeAttr('selected');
			$('#localcloseMinuteId' + value + ' > option:selected').removeAttr('selected');

			var openTime = new Date(Date.parse(locationTime.open)).toUTCString().split(" ")[4].split(":");
			var closeTime = new Date(Date.parse(locationTime.close)).toUTCString().split(" ")[4].split(":");

			$('#localopenHourId'+ value +' option[value="'+openTime[0]+'"]').attr("selected",true);
			$('#localopenMinuteId'+ value +' option[value="'+openTime[1]+'"]').attr("selected",true);
			$('#localcloseHourId'+ value +' option[value="'+closeTime[0]+'"]').attr("selected",true);
			$('#localcloseMinuteId'+ value +' option[value="'+closeTime[1]+'"]').attr("selected",true);
		});
		$('#location_pill_'+id).parent().addClass('active');
		$('#load_location_spinner').hide();
		$('#update_location_button').attr('name', 'edit_location_btn_'+id);
		if ($('#location_outcall').prop('checked')) {
      $('#location_outcall_places').closest(".form-group").toggle();
    }
	});
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
    }
  });

  $("#address").focusin(function () {
    $(document).bind("keypress.key1", function(e) {
      if (e.which == 13) {
        e.preventDefault();
        selectFirstResult();
      }
    });
  });
  $("#address").focusout(function () {
    selectFirstResult();
    $(document).unbind("keypress.key1");
  });

  function selectFirstResult() {
    $('#update_location_button').attr('disabled', true);
    infowindow.close();
    $(".pac-container").hide();
    var firstResult = $(".pac-container .pac-item:first").text();
    geocoder.geocode({"address":firstResult }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        setLatLng(results[0].geometry.location);
        setAddress(results[0]);
        setCenter(results[0].geometry.location);
      }
      else {
        $("#location_address").val('');
        $("#address").val('');
      }
    });
  }
  function geolocate() {
    $('#update_location_button').attr('disabled', true);
    if (navigator.geolocation) {
      $('#geolocate').html('<%= image_tag "small-loader.gif", :alt => "Loader", :id => "small_loader_header", :class => "small-loader-header" %>');
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
    $('#update_location_button').attr('disabled', false);
  }

  $('#geolocate').click(function() {
    geolocate();
  });
}

$(function() {

	$('#location_outcall').change(function() {
		$('#location_outcall_places').closest(".form-group").toggle();
	});

	$('#location_pills.nav-pills li a').click(function(event) {
		event.preventDefault();
		$('#load_location_spinner').show();
		$('#location_pills.nav-pills li').removeClass('active');
		if (event.target.id == "new_location_pill") {
			new_location();
		}
		else {
			if (parseInt(event.target.id.split("location_pill_")[1]) > 0) {
				load_location(parseInt(event.target.id.split("location_pill_")[1]));
			}
			else {
				window.console.log("Bad location link");
			}
		}
	});

	$('#next_location_button').click(function(){
		$('#fieldset_step3').show();
		$('#fieldset_step3').attr('disabled', false);
		scrollToAnchor('fieldset_step3');
	});
});
