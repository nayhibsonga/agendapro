var my_alert;
var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var local = 'local';
var prov = 'prov';

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
						'<select class="form-control" id="' + ctrl + 'openHourId'+ value +'" name="' + ctrl + 'openHour'+ value +'" disabled="disabled">' +
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
						'<select class="form-control" id="' + ctrl + 'openMinuteId'+ value +'" name="' + ctrl + 'openMinute'+ value +'" disabled="disabled">' +
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
						'<select class="form-control" id="' + ctrl + 'closeHourId'+ value +'" name="' + ctrl + 'closeHour'+ value +'" disabled="disabled">' +
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
						'<select class="form-control" id="' + ctrl + 'closeMinuteId'+ value +'" name="' + ctrl + 'closeMinute'+ value +'" disabled="disabled">' +
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
	var district = $('#location_district_id').val();
	var address = $('#location_address').val();
	if ((address != '')&&(district != '')) {
		$.getJSON('/get_direction', {id: district}, function (direction) {
			var geolocation = address + ', ' + direction;
			var geoString = JSON.stringify(geolocation);
			var geocoder = new google.maps.Geocoder();
			geocoder.geocode( { "address" : geoString }, function (results, status) {
				if (status == google.maps.GeocoderStatus.OK) {
					$('#location_latitude').val(results[0].geometry.location.lat());
					$('#location_longitude').val(results[0].geometry.location.lng());
				}
				else {
					my_alert.showAlert('Hubo un error geolocalizando su local.');
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
				}
			});
		});
	}
	else {
		my_alert.showAlert('Dirección y/o Comuna no pueden estar vacías.');
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
	var locationJSON  = {
		"name": $('#location_name').val(),
		"address": $('#location_address').val(),
		"phone": $('#location_phone').val(),
		"district_id": $('#location_district_id').val(),
		"latitude": parseFloat($('#location_latitude').val()),
		"longitude": parseFloat($('#location_longitude').val()),
		"location_times_attributes": location_times
	};
	return locationJSON;
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
	    		alert('success');
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
		}
	});
}

function serviceValid () {
	if (!$('#service_name').val()) {
		my_alert.showAlert('Debe escribir un nombre.');
	}
	else if (!$('#service_price').val()) {
		my_alert.showAlert('Debe elegir un precio.');
	}
	else if (!$('#service_duration').val()) {
		my_alert.showAlert('Debe elegir una duracion.');
	}
	else if (!$('#service_service_category_attributes_name').val()) {
		my_alert.showAlert('Debe elegir una categoria.');
	}
	else {
		$.ajax({
			type: 'POST',
			url: '/quick_add/services_valid',
			data: $('#new_service').serialize(),
			success: function (result) {
				if ($.parseJSON(result.valid)) {
		    		alert('success');
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
			}
		});
	}
}

function providerValid () {
	var bool = false;
	for(var i = 1; i < 8; ++i) {
		bool = bool || $('#provdayStatusId'+ i).is(':checked');
	}
	if (!$('#service_provider_public_name').val()) {
		my_alert.showAlert('Debe elegir un nombre público.');
	}
	else if (!$('#service_provider_notification_email').val()) {
		my_alert.showAlert('Debe elegir un email de notificación.');
	}
	else if (!bool) {
		my_alert.showAlert('Debe elegir al menos un día.');
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
		    success: function(data){
		    	if ($.parseJSON(result.valid)) {
		    		alert('success');
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
	    	$('#service_provider_location_id').parent().append('<span>' + result.name + '</span>');
	    	/*
	    	avansar el quick add
	    	*/
	    	// document.location.href = '/locations/';
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
		}
	});
}

function createService () {
	$.ajax({
		type: 'POST',
		url: '/quick_add/services',
		data: $('#new_service').serialize(),
		success: function (result) {
			alert('services')
			//Make something
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
		}
	});
}

function createProvider () {
	var bool = false;
	for(var i = 1; i < 8; ++i) {
		bool = bool || $('#provdayStatusId'+ i).is(':checked');
	}
	if (!$('#service_provider_public_name').val()) {
		my_alert.showAlert('Debe elegir un nombre público.');
	}
	else if (!$('#service_provider_notification_email').val()) {
		my_alert.showAlert('Debe elegir un email de notificación.');
	}
	else if (!bool) {
		my_alert.showAlert('Debe elegir al menos un día.');
	}
	else {
		var enabledDays = [];
		for(var i = 1; i < 8; ++i) {
			if ($('#provdayStatusId'+ i).val() == 1) {
				enabledDays.push($('#provdayStatusId'+ i).attr('id').slice(-1));
			}
		}
		// $(".dayCheckbox").each( function() {
		// 	if ($( this ).val() == 1) {
		// 		enabledDays.push($(this).attr('id').slice(-1));
		// 	}
		// });
		// var enabledServices = [];
		// $("input.check_boxes").each( function() {
		// 	if ($(this).prop('checked')) {
		// 		enabledServices.push($.parseJSON($(this).val()));
		// 	}
		// });
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
		    	alert('service_provider')
		    	// document.location.href = '/dashboard/';
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
			}
		});
	}
}

function scrollEvents (direction) {
	return true;
}

$(function() {
  initialize('local');
  initialize('prov');
  my_alert = new Alert();
});