var my_alert;
var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var local = 'local';
var prov = 'prov';
var nextFn;

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
							'<option value="09">09</option>' +
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
							'<option value="00">00</option>' +
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
							'<option value="18">18</option>' +
							'<option value="19">19</option>' +
							'<option value="20">20</option>' +
							'<option value="21">21</option>' +
							'<option value="22">22</option>' +
							'<option value="23">23</option>' +
						'</select>' +
					'</div> : ' +
					'<div class="form-group">' +
						'<select class="form-control time-select" id="' + ctrl + 'closeMinuteId'+ value +'" name="' + ctrl + 'closeMinute'+ value +'" disabled="disabled">' +
							'<option value="00">00</option>' +
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
					my_alert.showAlert('Tiene que seleccionar al menos un día.');
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
					my_alert.showAlert('Tiene que seleccionar al menos un día.');
					hideLoad();
				}
			});
		});
	}
	else {
		my_alert.showAlert('Dirección y/o Comuna no pueden estar vacías.');
		hideLoad();
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

function loadProvider () {
	var location_id = $('#service_provider_location_id').val();
	$.getJSON('/location_time', {id: location_id}, function (times) {
		$.each(times, function (key, time) {
			$('#' + prov + 'openHourId'+ time.day_id).prop('disabled', false);
			$('#' + prov + 'openMinuteId'+ time.day_id).prop('disabled', false);
			$('#' + prov + 'closeHourId'+ time.day_id).prop('disabled', false);
			$('#' + prov + 'closeMinuteId'+ time.day_id).prop('disabled', false);

			var openTime = new Date(Date.parse(time.open)).toUTCString().split(" ")[4].split(":");
			$('#' + prov + 'openHourId'+ time.day_id +' option[value="'+openTime[0]+'"]').attr("selected",true);
			$('#' + prov + 'openMinuteId'+ time.day_id +' option[value="'+openTime[1]+'"]').attr("selected",true);
			var closeTime = new Date(Date.parse(time.close)).toUTCString().split(" ")[4].split(":");
			$('#' + prov + 'closeHourId'+ time.day_id +' option[value="'+closeTime[0]+'"]').attr("selected",true);
			$('#' + prov + 'closeMinuteId'+ time.day_id +' option[value="'+closeTime[1]+'"]').attr("selected",true);

			$('#' + prov + 'dayStatusId' + time.day_id).prop('checked', true);
			changeDayStatus(time.day_id, prov);
		});
	});
}

// Validations
function locationValid (ctrl) {
	var locationJSON = locJSON(ctrl);
	$.ajax({
	    type: "POST",
	    url: '/quick_add/location_valid.json',
	    data: { "location": locationJSON },
	    dataType: 'json',
	    success: function (result){
	    	if ($.parseJSON(result.valid)) {
	    		saveLocation(ctrl);
	    	}
	    	else {
	    		var errors = result.errors;
	    		var error_text = '';
			    for (i in errors) {
			    	error_text += '<li>' + errors[i] + '</li>';
			    }
			    my_alert.showAlert(
			    	'<h4>Error</h4>' +
			    	'<ul>' +
			    		error_text +
			    	'</ul>'
			    );
				hideLoad();
	    	}
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var error_text = '';
		    for (i in errors) {
		    	error_text += '<li>' + errors[i] + '</li>';
		    }
		    my_alert.showAlert(
		    	'<h4>Error</h4>' +
		    	'<ul>' +
		    		error_text +
		    	'</ul>'
		    );
			hideLoad();
		}
	});
}

function serviceValid () {
	if (!$('#new_service').valid()) {
		hideLoad();
		return false;
	};
	if (!$('#service_name').val()) {
		my_alert.showAlert('Debe escribir un nombre.');
		hideLoad();
	}
	else if (!$('#service_price').val()) {
		my_alert.showAlert('Debe elegir un precio.');
		hideLoad();
	}
	else if (!$('#service_duration').val()) {
		my_alert.showAlert('Debe elegir una duracion.');
		hideLoad();
	}
	else if (!$('#service_service_category_attributes_name').val() && !$('#service_service_category_id').val()) {
		my_alert.showAlert('Debe elegir una categoria.');
		hideLoad();
	}

	else {
		$.ajax({
			type: 'POST',
			url: '/quick_add/services_valid',
			data: $('#new_service').serialize(),
			success: function (result) {
				if ($.parseJSON(result.valid)) {
		    		createService();
		    	}
		    	else {
		    		var errors = result.errors;
		    		var error_text = '';
				    for (i in errors) {
				    	error_text += '<li>' + errors[i] + '</li>';
				    }
				    my_alert.showAlert(
				    	'<h4>Error</h4>' +
				    	'<ul>' +
				    		error_text +
				    	'</ul>'
				    );
				    hideLoad()
		    	}
			},
			error: function (xhr) {
				var errors = $.parseJSON(xhr.responseText).errors;
			    var error_text = '';
			    for (i in errors) {
			    	error_text += '<li>' + errors[i] + '</li>';
			    }
			    my_alert.showAlert(
			    	'<h4>Error</h4>' +
			    	'<ul>' +
			    		error_text +
			    	'</ul>'
			    );
			    hideLoad()
			}
		});
	}
}

function providerValid () {
	if (!$('#new_service_provider').valid()) {
		hideLoad();
		return false;
	};
	var bool = false;
	for(var i = 1; i < 8; ++i) {
		bool = bool || $('#provdayStatusId'+ i).is(':checked');
	}
	if (!$('#service_provider_public_name').val()) {
		my_alert.showAlert('Debe elegir un nombre público.');
		hideLoad();
	}
	else if (!$('#service_provider_notification_email').val()) {
		my_alert.showAlert('Debe elegir un email de notificación.');
		hideLoad();
	}
	else if (!bool) {
		my_alert.showAlert('Debe elegir al menos un día.');
		hideLoad();
	}
	else {
		var enabledDays = [];
		for(var i = 1; i < 8; ++i) {
			if ($('#provdayStatusId'+ i).val() == 1) {
				enabledDays.push($('#provdayStatusId'+ i).attr('id').slice(-1));
			}
		}
		var provider_times = [];
		for (i in enabledDays) {
			var provider_time = {"open":"2000-01-01T"+ $('#provopenHourId'+enabledDays[i]).val() +":"+ $('#provopenMinuteId'+enabledDays[i]).val() +":00Z","close":"2000-01-01T"+ $('#provcloseHourId'+enabledDays[i]).val() +":"+ $('#provcloseMinuteId'+enabledDays[i]).val() +":00Z","day_id":parseInt(enabledDays[i])};
			provider_times.push(provider_time);
		}
		var providerJSON  = {
			"public_name": $('#service_provider_public_name').val(),
			"notification_email": $('#service_provider_notification_email').val(),
			"location_id": parseInt($('#service_provider_location_id').val()),
			// "user_id": parseInt($('#service_provider_user_id').val()),
			// "service_ids": enabledServices,
			"provider_times_attributes": provider_times
		};
		$.ajax({
		    type: "POST",
		    url: '/quick_add/service_provider_valid.json',
		    data: { "service_provider": providerJSON },
		    dataType: 'json',
		    success: function(result){
		    	if ($.parseJSON(result.valid)) {
		    		createProvider();
		    	}
		    	else {
		    		var errors = result.errors;
		    		var error_text = '';
				    for (i in errors) {
				    	error_text += '<li>' + errors[i] + '</li>';
				    }
				    my_alert.showAlert(
				    	'<h4>Error</h4>' +
				    	'<ul>' +
				    		error_text +
				    	'</ul>'
				    );
				    hideLoad();
		    	}
			},
			error: function(xhr){
			    var errors = $.parseJSON(xhr.responseText).errors;
			    var error_text = '';
			    for (i in errors) {
			    	error_text += '<li>' + errors[i] + '</li>';
			    }
			    my_alert.showAlert(
			    	'<h4>Error</h4>' +
			    	'<ul>' +
			    		error_text +
			    	'</ul>'
			    );
			    hideLoad();
			}
		});
	}
}

// Post
function saveLocation (ctrl) {
	var locationJSON = locJSON(ctrl);
	$.ajax({
	    type: "POST",
	    url: '/quick_add/location.json',
	    data: { "location": locationJSON },
	    dataType: 'json',
	    success: function (result){
	    	$('#service_provider_location_id').val(result.id);
	    	$('#service_provider_location_id').parent().append('<p class="form-control-static">' + result.name + '</p>');
	    	if (result.outcall) {
	    		$('#service_outcall').prop('checked', true);
	    		$('#service_outcall').prop('disabled', true);	
	    	}

	    	nextFn = serviceValid;
    		$('#foo5').trigger('nextPage');
    		hideLoad();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var error_text = '';
		    for (i in errors) {
		    	error_text += '<li>' + errors[i] + '</li>';
		    }
		    my_alert.showAlert(
		    	'<h4>Error</h4>' +
		    	'<ul>' +
		    		error_text +
		    	'</ul>'
		    );
			hideLoad();
		}
	});
}

function createService () {
	$.ajax({
		type: 'POST',
		url: '/quick_add/services',
		data: $('#new_service').serialize(),
		success: function (result) {
			loadProvider();
			nextFn = providerValid;
			$('#foo5').trigger('nextPage');
    		hideLoad();
		},
		error: function (xhr) {
			var errors = $.parseJSON(xhr.responseText).errors;
		    var error_text = '';
		    for (i in errors) {
		    	error_text += '<li>' + errors[i] + '</li>';
		    }
		    my_alert.showAlert(
		    	'<h4>Error</h4>' +
		    	'<ul>' +
		    		error_text +
		    	'</ul>'
		    );
			hideLoad();
		}
	});
}

function createProvider () {
	var enabledDays = [];
	for(var i = 1; i < 8; ++i) {
		if ($('#provdayStatusId'+ i).val() == 1) {
			enabledDays.push($('#provdayStatusId'+ i).attr('id').slice(-1));
		}
	}
	var provider_times = [];
	for (i in enabledDays) {
		var provider_time = {"open":"2000-01-01T"+ $('#provopenHourId'+enabledDays[i]).val() +":"+ $('#provopenMinuteId'+enabledDays[i]).val() +":00Z","close":"2000-01-01T"+ $('#provcloseHourId'+enabledDays[i]).val() +":"+ $('#provcloseMinuteId'+enabledDays[i]).val() +":00Z","day_id":parseInt(enabledDays[i])};
		provider_times.push(provider_time);
	}
	var providerJSON  = {
		"public_name": $('#service_provider_public_name').val(),
		"notification_email": $('#service_provider_notification_email').val(),
		"location_id": parseInt($('#service_provider_location_id').val()),
		// "user_id": parseInt($('#service_provider_user_id').val()),
		// "service_ids": enabledServices,
		"provider_times_attributes": provider_times
	};
	$.ajax({
	    type: "POST",
	    url: '/quick_add/service_provider.json',
	    data: { "service_provider": providerJSON },
	    dataType: 'json',
	    success: function(data){
	    	hideLoad();
	    	document.location.href = '/dashboard/';
		},
		error: function(xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var error_text = '';
		    for (i in errors) {
		    	error_text += '<li>' + errors[i] + '</li>';
		    }
		    my_alert.showAlert(
		    	'<h4>Error</h4>' +
		    	'<ul>' +
		    		error_text +
		    	'</ul>'
		    );
		    hideLoad();
		}
	});
}

// Views
function serviceGroup () {
	if ($('#service_group_service').is(':checked')) {
		$('#service_capacity').closest('.form-group').removeClass('hidden');
		$('#service_capacity').attr('disabled', false);
	}
	else {
		$('#service_capacity').closest('.form-group').addClass('hidden');
		$('#service_capacity').attr('disabled', true);
	}
	$('#foo5').trigger('updateSizes');
}

function newCategory () {
	if ($('#categoryCheckboxId').is(':checked')) {
		$('#service_service_category_id').closest('.form-group').addClass('hidden');
		$('#service_service_category_id').val('');
		$('#service_service_category_attributes_name').closest('.form-group').removeClass('hidden');
		$('#service_service_category_attributes_name').focus();
		$('#service_service_category_id').attr('disabled', true);
		$('#service_service_category_attributes_name').attr('disabled', false);
	}
	else {
		$('#service_service_category_id').closest('.form-group').removeClass('hidden');
		$('#service_service_category_attributes_name').closest('.form-group').addClass('hidden');
		$('#service_service_category_attributes_name').val('');
		$('#service_service_category_id').attr('disabled', false);
		$('#service_service_category_attributes_name').attr('disabled', true);
	}
}

// Caroufredsel Methods
function showLoad () {
	$('#next2').addClass('disabled');
	$('.center-block').parent().removeClass('hidden');
  	$('#foo5').css('visibility', 'collapse');
}

function hideLoad () {
	$('.center-block').parent().addClass('hidden');
  	$('#foo5').css('visibility', 'visible');
	$('#next2').removeClass('disabled');
	$('#foo5').trigger('updateSizes');
}

function scrollEvents () {
	showLoad();
	nextFn();
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
			$('#foo5').trigger('updateSizes');
		};
	});
}

$(function() {
	nextFn = startLocation;
	initialize('local');
	initialize('prov');
	$('#service_group_service').click(function (e) {
		serviceGroup();
	});
	my_alert = new Alert();
	$('#country').change(function (event) {
		$('#region').attr('disabled', true);
		$('#city').attr('disabled', true);
		$('#location_district_id').attr('disabled', true);
		var country_id = $(event.target).val();
		changeCountry(country_id);
	});
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
		$('#foo5').trigger('updateSizes');
	});
	$('#service_outcall').change(function() {
		if (!$('#service_outcall').prop('checked')) {
			$('#outcallTip').addClass('hidden');
		}
		else {
			$('#outcallTip').removeClass('hidden');
		}
		$('#foo5').trigger('updateSizes');
	});
});