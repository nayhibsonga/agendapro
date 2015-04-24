function initializeStep2 () {
	$('#fieldset_step2').removeAttr('disabled');
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

function startLocation () {
	if (!$('#new_location').valid()) {
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

// // Validations
// function locationValid (ctrl) {
// 	var locationJSON = locJSON(ctrl);
// 	$.ajax({
// 	    type: "POST",
// 	    url: '/quick_add/location_valid.json',
// 	    data: { "location": locationJSON },
// 	    dataType: 'json',
// 	    success: function (result){
// 	    	if ($.parseJSON(result.valid)) {
// 	    		saveLocation(ctrl);
// 	    	}
// 	    	else {
// 	    		var errors = result.errors;
// 	    		var errorList = '';
// 				for (i in errors) {
// 					errorList += '<li>' + errors[i] + '</li>'
// 				}
// 				my_alert.showAlert(
// 					'<h3>Error</h3>' +
// 					'<ul>' +
// 						errorList +
// 					'</ul>'
// 				);
// 	    	}
// 		},
// 		error: function (xhr){
// 		    var errors = $.parseJSON(xhr.responseText).errors;
// 		    var errorList = '';
// 			for (i in errors) {
// 				errorList += '<li>' + errors[i] + '</li>'
// 			}
// 			my_alert.showAlert(
// 				'<h3>Error</h3>' +
// 				'<ul>' +
// 					errorList +
// 				'</ul>'
// 			);
// 			hideLoad();
// 		}
// 	});
// }

function saveLocation (typeURL, extraURL) {
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
				$('#new_location_pill').parent().before('<li><a href="#" id="location_pill_'+result.id+'">'+result.name+'<!--  <button id="location_delete_'+result.id+'" class="btn btn-danger btn-xs"><i class="fa fa-trash-o"></i></button> --></a></li>');
				$('#location_pill_'+result.id).click(function(event){
					event.preventDefault();
					$('#load_location_spinner').show();
					$('#location_pills.nav-pills li').removeClass('active');
					load_location(result.id);
				});
			}
			else {
				$('#location_pill_'+result.id).html(result.name);
			}
			$('#update_location_spinner').hide();
			$('#update_location_button').atrr('disabled', false);
			$('#next_location_button').atrr('disabled', false);
	    	new_location();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_location_spinner').hide();
			$('#update_location_button').atrr('disabled', false);
			$('#next_location_button').atrr('disabled', false);
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

function new_location() {
	$('#location_name').val('');
	$('#location_address').val('');
	$('#location_second_address').val('');
	$('#location_phone').val('');
	$('#location_district_id').val('');
	$('#location_outcall').prop('checked', false);
	$('#location_latitude').val('');
	$('#location_longitude').val('');
	$('#location_address').attr('disabled', false);
	$('#location_second_address').attr('disabled', false);
	$('#location_district_ids').val('');
	$('#districtsCheckboxes').addClass('hidden');
	$('#country option[value=""]').prop('selected', true);
	$('#region option[value=""]').prop('selected', true);
	$('#region').attr('disabled', true);
	$('#city option[value=""]').prop('selected', true);
	$('#city').attr('disabled', true);
	$('#location_district_id option[value=""]').prop('selected', true);
	$('#location_district_id').attr('disabled', true);
	$('#districtsCheckboxes').empty();
	$('#update_location_button').attr('name', 'new_location_btn');
	$('#new_location_pill').parent().addClass('active');
	$('#load_location_spinner').hide();
	initialize('local');
}

function load_location(id) {
	$.getJSON('/quick_add/load_location/'+id, {}, function (location) {
		$('#location_name').val(location.location.name);
		$('#location_address').val(location.location.address);
		$('#location_second_address').val(location.location.second_address);
		$('#location_phone').val(location.location.phone);
		$('#location_outcall').prop('checked', location.location.outcall);
		$('#location_latitude').val(location.location.latitude);
		$('#location_longitude').val(location.location.longitude);
		$('#location_address').attr('disabled', false);
		$('#location_second_address').attr('disabled', false);
	    var latitude = parseFloat($('#location_latitude').val());
	    var longitude = parseFloat($('#location_longitude').val());
	    setCenter(new google.maps.LatLng(latitude, longitude), 17);
		$.each(location.location_times, function(index,locationTime) {
			window.console.log()
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
		$('#country option[value="'+location.country_id+'"]').attr("selected",true);
	    $.getJSON('/country_regions', {country_id: location.country_id}, function (regions) {
	      if (regions.length > 0) {
	        $('#region').empty();
	        $.each(regions, function (key, region) {
	          $('#region').append(
	            '<option value="' + region.id + '">' + region.name + '</option>'
	          );
	        });
	        $('#region').prepend(
	          '<option></option>'
	        );
	        $('#region').attr('disabled', false);
	        $('#region option[value="'+location.region_id+'"]').attr("selected",true);
	        $('#region').change(function (event) {
	          $('#city').attr('disabled', true);
	          $('#city').val('');
	          $('#location_district_id').attr('disabled', true);
	          $('#location_district_id').val('');
	          var region_id = $(event.target).val();
	          changeRegion(region_id);
	        });
	        $.getJSON('/region_cities', {region_id: location.region_id}, function (cities) {
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
	            $('#city').attr('disabled', false);
	            $('#city option[value="'+location.city_id+'"]').attr("selected",true);
	            $('#city').change(function (event) {
	              $('#location_district_id').attr('disabled', true);
	              $('#location_district_id').val('');
	              var city_id = $(event.target).val();
	              changeCity(city_id);
	            });
	            $.getJSON('/city_districs', {city_id: location.city_id}, function (districts) {
	              if (districts.length) {
	                $('#location_district_id').empty();
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
	                $('#location_district_id option[value="'+location.location.district_id+'"]').attr("selected",true);
	                if (location.location.outcall) {
	                  $('#location_address').attr('disabled', true);
	                  $('#location_second_address').attr('disabled', true);
	                  $('#districtsCheckboxes').removeClass('hidden');
	                  $.each(location.location_districts, function(index,locationDistrict) {
	                    $('.districtActive[value="'+locationDistrict.district_id+'"]').prop('checked',true);
	                  });
	                }
	              };
				$('#location_pill_'+id).parent().addClass('active');
				$('#load_location_spinner').hide();
				$('#update_location_button').attr('name', 'edit_location_btn_'+id);
	            });
	          };
	        });
	      };
	    });
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
	$('#location_outcall').change(function() {
		$('#location_outcall').parents('.form-group').removeClass('has-error has-success');
		$('#location_outcall').parents('.form-group').find('.help-block').empty();
		$('#location_outcall').parents('.form-group').find('.form-control-feedback').removeClass('fa fa-times fa-check')
		if (!$('#location_outcall').prop('checked')) {
			$('#location_address').attr('disabled', false);
			$('#location_second_address').attr('disabled', false);
			$('#location_district_ids').val('');
			$('#districtsCheckboxes').addClass('hidden');
		}
		else {
			$('#location_address').attr('disabled', true);
			$('#location_second_address').attr('disabled', true);
			$('#location_address').val('');
			$('#location_second_address').val('');
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

	$('#update_location_button').click(function(event) {
		$('#update_location_spinner').show();
		$('#update_location_button').atrr('disabled', true);
		$('#next_location_button').atrr('disabled', true);
		if(event.target.name == 'new_location_btn') {
			saveLocation('POST','');
		}
		else {
			if (parseInt(event.target.name.split("edit_location_btn_")[1]) > 0) {
				saveLocation('PATCH', '/'+parseInt(event.target.name.split("edit_location_btn_")[1]));
			}
			else {
				window.console.log("Bad location update");
			}
		}
	});

	$('#next_location_button').click(function(){
		scrollToAnchor('quick_add_step3');
	});
});