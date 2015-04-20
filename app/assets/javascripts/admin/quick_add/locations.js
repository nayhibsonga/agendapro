function initializeStep2 () {
	$('#fieldset_step2').removeAttr('disabled');
	scrollToAnchor("quick_add_step2");
	createMap();
	initialize('local');
}

var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var local = 'local';

function buildDay (value, ctrl) {
	$('#' + ctrl + 'Table').append(
		'<tr>' +
			'<th>' +
				'<div class="checkbox">' +
				    '<label>' +
				    	'<input type="checkbox" name="' + ctrl + 'dayStatus'+ value +'" id="' + ctrl + 'dayStatusId'+ value +'" value="0" onchange="changeDayStatus('+ value +',' + ctrl + ')"> ' + days[value - 1] + ':' +
				    '</label>' +
				'</div>' +
			'</th>' +
			'<th>' +
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
				'</form>' +
			'</th>' +
			'<th>' +
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
			'</th>' +
		'</tr>'
  	);
}

function initialize (ctrl) {
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

function startLocation () {
	if (!$('#new_location').valid()) {
		hideLoad();
		return false;
	};
	if ((!$('#location_outcall').prop('checked')) && ($('#location_address').val() != '') && ($('#location_district_id').val() != '')) {
		$.getJSON('/get_direction', {id: $('#location_district_id').val()}, function (direction) {
			var geolocation = $('#location_address').val() + ', ' + direction;
			var geoString = JSON.stringify(geolocation);
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode( { "address" : geoString }, function (results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					$('#location_latitude').val(results[0].geometry.location.lat());
					$('#location_longitude').val(results[0].geometry.location.lng());
				}
				// Al menos un dia seleccionado
				var bool = false;
				for(var i = 1; i < 8; ++i) {
					bool = bool || $('#localdayStatusId'+ i).is(':checked');
				}
				if (bool) {
					locationValid(local);
				}
				else {
					my_alert.showAlert('Tienes que seleccionar al menos un día.');
					hideLoad();
				}
			});
		});
	}
	else if ($('#location_outcall').prop('checked') && $('#location_district_id').val() != '') {
		$.getJSON('/get_direction', {id: $('#location_district_id').val()}, function (direction) {
			var geolocation = direction;
			var geoString = JSON.stringify(geolocation);
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode( { "address" : geoString }, function (results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					$('#location_latitude').val(results[0].geometry.location.lat());
					$('#location_longitude').val(results[0].geometry.location.lng());
				}
				// Al menos un dia seleccionado
				var bool = false;
				for(var i = 1; i < 8; ++i) {
					bool = bool || $('#localdayStatusId'+ i).is(':checked');
				}
				if (bool) {
					locationValid(local);
				}
				else {
					my_alert.showAlert('Tienes que seleccionar al menos un día.');
					hideLoad();
				}
			});
		});
	}
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
	var districtIds = [];
	if ($('#location_outcall').prop('checked')) {
		$(".districtActive:checked").each(
		    function() {
		    	districtIds.push($(this).val());
		    }
		);
	}
	var locationJSON  = {
		"name": $('#location_name').val(),
		"address": $('#location_address').val(),
		"second_address": $('#location_second_address').val(),
		"phone": $('#location_phone').val(),
		"district_id": $('#location_district_id').val(),
		"outcall": $('#location_outcall').prop('checked'),
		"district_ids": districtIds,
		"latitude": parseFloat($('#location_latitude').val()),
		"longitude": parseFloat($('#location_longitude').val()),
		"location_times_attributes": location_times
	};
	return locationJSON;
}

function changeCountry (country_id) {
	$.getJSON('/country_regions', {country_id: country_id}, function (regions) {
		if (regions.length) {
			$('#region').empty();
			$.each(regions, function (key, region) {
				$('#region').append(
					'<option value="' + region.id + '">' + region.name + '</option>'
				);
			});
			$('#region').prepend(
				'<option></option>'
			);

			$('#region').change(function (event) {
				$('#city').attr('disabled', true);
				$('#location_district_id').attr('disabled', true);
				var region_id = $(event.target).val();
				changeRegion(region_id);
			});
			$('#region').attr('disabled', false);
		};
	});
}

function changeRegion (region_id) {
	$.getJSON('/region_cities', {region_id: region_id}, function (cities) {
		if (cities.length) {
			$('#city').empty();
			$.each(cities, function (key, city) {
				$('#city').append(
					'<option value="' + city.id + '">' + city.name + '</option>'
				);
			});
			$('#city').prepend(
				'<option></option>'
			);

			$('#city').change(function (event) {
				$('#location_district_id').attr('disabled', true);
				var city_id = $(event.target).val();
				changeCity(city_id);
			});
			$('#city').attr('disabled', false);
		};
	});
}

function changeCity (city_id) {
	$.getJSON('/city_districs', {city_id: city_id}, function (districts) {
		if (districts.length) {
			$('#location_district_id').empty();
			$('#districtsCheckboxes').empty();
			$('#districtsCheckboxes').html('<div class="panel panel-info"><div class="panel-heading"><h3 class="panel-title">Comunas que atiendes</h3></div><div id="districtsPanel" class="panel-body"></div></div>');
			$.each(districts, function (key, district) {
				$('#location_district_id').append(
					'<option value="' + district.id + '">' + district.name + '</option>'
				);
				$('#districtsPanel').append(
					'<input type="checkbox" value="' + district.id + '" class="districtActive"/> ' + district.name + '<br />'
				);
			});
			$('#location_district_id').attr('disabled', false);
			var oldTop = $(document).scrollTop();
			$('#foo5').trigger('updateSizes');
			$(document).scrollTop(oldTop);
		};
	});
}

/*** Google Maps ***/
var map;
var marker;
function createMap () {
  var mapProp = {
    center: new google.maps.LatLng(-33.412819, -70.591945),
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
  if (!$('#error').hasClass('hide')) {
    $('#error').addClass('hide');
  };
  if (marker) {
    marker.setMap(null);
  };
  map.panTo(latLng);
  map.setCenter(latLng);
  map.setZoom(zoom);
  setMarker(latLng);
  $('#location_latitude').val(latLng.lat());
  $('#location_longitude').val(latLng.lng());
  $('h4 small').addClass('hide');
}

function geolocate (district, address) {
  $('h4 small').removeClass('hide');
  $.getJSON('/get_direction', { id: district }, function (direction) {
    var geolocation = direction;
    var zoom = 15;
    if (!$('#location_outcall').prop('checked')) {
      geolocation = $('#location_address').val() + ', ' + geolocation;
      zoom = 17;
    };
    var geocoder = new google.maps.Geocoder();
    geocoder.geocode({ "address": JSON.stringify(geolocation) }, function (results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        setCenter(results[0].geometry.location, zoom);
      } else {
        $('h4 small').addClass('hide');
        $('#error').removeClass('hide');
        map.setZoom(12);
        if (marker) {
          marker.setMap(null);
        };
      };
    });
  });
}

$(function() {
	initialize('prov');
	$('#location_outcall').change(function() {
		$('#location_outcall').parents('.form-group').removeClass('has-error has-success');
		$('#location_outcall').parents('.form-group').find('.help-block').empty();
		$('#location_outcall').parents('.form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check')
		if (!$('#location_outcall').prop('checked')) {
			$('#location_address').attr('disabled', false);
			$('#location_district_ids').val('');
			$('#districtsCheckboxes').addClass('hidden');
		}
		else {
			$('#location_address').attr('disabled', true);
			$('#location_address').val('');
			$('#districtsCheckboxes').removeClass('hidden');
		}
	});

	$('#country').change(function (event) {
		$('#region').attr('disabled', true);
		$('#city').attr('disabled', true);
		$('#location_district_id').attr('disabled', true);
		var country_id = $(event.target).val();
		changeCountry(country_id);
	});
	$('#location_district_id, #location_address, #location_outcall').change(function (eve) {
		var district = $('#location_district_id').val();
		var address = $('#location_address').val();
		if (district != '') {
		  if ($('#location_outcall').prop('checked') || address.length > 0) {
		    geolocate(district, address);
		  };
		};
	});
	
	$('#location_district_id, #location_address, #location_outcall').change(function (eve) {
		var district = $('#location_district_id').val();
		var address = $('#location_address').val();
		if (district != '') {
		  if ($('#location_outcall').prop('checked') || address.length > 0) {
		    geolocate(district, address);
		  };
		};
	});
});