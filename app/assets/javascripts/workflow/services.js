function loadStep1() {
	stepClick(1);
	if ($('[name="localRadio"]').is(':checked')) {
		$('#services-selector').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
		var localId = $('input[name=localRadio]:checked').val();
		$.getJSON('/localServices', {location: localId}, function (servicesArray) {
			$('#services-selector').empty();
			$.each(servicesArray, function (key, services) {
				$.each(services, function (key, service) {
					$('#services-selector').append('<label>' +
							'<input type="radio" name="serviceRadio" value="' + service.id + '">' +
							'<p>' + service.name + '</p>' +
						'</label>'
					);
				});
			});
			$('[name="serviceRadio"]').on('click', function(event) {
				var serviceId = event.target.getAttribute('value');
				loadDescription(serviceId);
			});
		});
		return true;
	}
	return false;
}

function loadDescription (serviceId) {
	$('#services-description').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
	$.getJSON('/services/' + serviceId + '.json', function (service) {
		$('#services-description').html('');
		$('#services-description').html('<dl class="dl-horizontal"></dl>');
		$('.dl-horizontal').append('<dt>' + "Nombre" + '</dt><dd>' + service.name + '</dd>');
		$('.dl-horizontal').append('<dt>' + "Precio" + '</dt><dd>$' + service.price + '</dd>');
		$('.dl-horizontal').append('<dt>' + "Duración" + '</dt><dd>' + service.duration + ' Minutos</dd>');
		if(service.description) {
			$('.dl-horizontal').append('<dt>' + "Descripción" + '</dt><dd>' + service.description + '</dd>');
		}
	});
}

function loadStep2() {
	if($('[name="serviceRadio"]').is(':checked')){
		$('#staff-selector').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
		var serviceId = $('input[name=serviceRadio]:checked').val();
		var minHour = 23;
		var minMinuts = 59;
		var maxHour = 00;
		var maxMinuts = 00;
		$.getJSON('/serviceProviders', {id: serviceId}, function (providers) {
			$('#staff-selector').empty();
			$.each(providers, function (key, provider) {
				$('#staff-selector').append('<label>' +
						'<input type="radio" name="staffRadio" value="' + provider.id + '">' +
						'<p>Provider: ' + provider.id + '</p>' +
					'</label>'
				);
				$.ajax({
					type: 'GET',
					url: '/providerTime',
					async: false,
					contentType: 'application/json',
					dataType: 'json',
					data: {
						id: provider.id
					},
					success: function (times) {
						$.each(times, function (key, time) {
								var openHour = parseInt(getHour(time.open).substr(0, getHour(time.open).indexOf(':')));
								var openMinuts = parseInt(getHour(time.open).substr(getHour(time.open).indexOf(':') + 1));
								var closeHour = parseInt(getHour(time.close).substr(0, getHour(time.close).indexOf(':')));
								var closeMinuts = parseInt(getHour(time.close).substr(getHour(time.close).indexOf(':') + 1));
								if(openHour < minHour) {
									minHour = openHour;
									minMinuts = openMinuts;
								}
								else if (openHour == minHour) {
									if(openMinuts < minMinuts) {
										minMinuts = openMinuts;
									}
								}
								if(closeHour > maxHour) {
									maxHour = closeHour;
									maxMinuts = closeMinuts;
								}
								else if (closeHour == maxHour) {
									if(closeMinuts > maxMinuts) {
										maxMinuts = closeMinuts;
									}
								}
						});
					}
				});
			});
			$('[name="staffRadio"]').on('click', function(event) {
				var providerId = event.target.getAttribute('value');
				loadProviderTime(providerId);
			});
			loadCalendar(minHour + ':' + minMinuts, maxHour + ':' + maxMinuts);
			$.each(providers, function (key, provider) {
				loadProviderBooking(provider.id);
			});
		});
		/*
		 * Ademas cargar el horario conjunto de los staffs.
		 * Al seleccionar un staff cargar el horario particular
		*/
		return true;
	}
	alert('Debe elegir un Servicio')
	return false;
}

function loadStep3() {
	alert('step 3')
	return true;
}

function loadStep4() {
	alert('step 4')
	return true;
}

function finalize() {
	alert('finalize')
	return true;
}

function loadCalendar(startTime, endTime) {
	//Default values
	startTime = startTime || 0;
	endTime = endTime || 24;

	$('#calendar').empty();
	$('#calendar').fullCalendar({
	    header: {
	    	left: 'title',
	    	center: 'agendaWeek,agendaDay',
	    	right: 'prev,today,next'
	    },
	    firstDay: 1,	//Lunes
	    defaultView: 'agendaWeek',
	    allDaySlot: false,
	    axisFormat: 'HH:mm',
	    timeFormat: 'HH:mm{ - HH:mm}',
	    columnFormat: {
	    	week: 'ddd d/M',
	    	day: 'dddd d/M' 
	    },
	    titleFormat: {
	    	week: 'MMM d[ yyyy]{ &#8212;[ MMM] d yyyy}',
	    	day: 'dddd, d MMM yyyy'  
	    },
	    buttonText: {
		    prev:     '&lsaquo;', // <
		    next:     '&rsaquo;', // >
		    today:    'Hoy',
		    week:     'Semana',
		    day:      'Día'
	    },
	    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
	    monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
	    dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
	    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
	    minTime: startTime,
	    maxTime: endTime
	});
}

function loadProviderTime(providerId) {
	$.getJSON('/providerTime', {id: providerId}, function (times) {
		var minHour = 23;
		var minMinuts = 59;
		var maxHour = 00;
		var maxMinuts = 00;
		$.each(times, function (key, time) {
				var openHour = parseInt(getHour(time.open).substr(0, getHour(time.open).indexOf(':')));
				var openMinuts = parseInt(getHour(time.open).substr(getHour(time.open).indexOf(':') + 1));
				var closeHour = parseInt(getHour(time.close).substr(0, getHour(time.close).indexOf(':')));
				var closeMinuts = parseInt(getHour(time.close).substr(getHour(time.close).indexOf(':') + 1));
				if(openHour < minHour) {
					minHour = openHour;
					minMinuts = openMinuts;
				}
				else if (openHour == minHour) {
					if(openMinuts < minMinuts) {
						minMinuts = openMinuts;
					}
				}
				if(closeHour > maxHour) {
					maxHour = closeHour;
					maxMinuts = closeMinuts;
				}
				else if (closeHour == maxHour) {
					if(closeMinuts > maxMinuts) {
						maxMinuts = closeMinuts;
					}
				}
		});
		loadCalendar(minHour + ':' + minMinuts, maxHour + ':' + maxMinuts);
		loadProviderBooking(providerId);
	});
}

function loadProviderBooking(providerId) {
	var localId = $('input[name=localRadio]:checked').val();
	var serviceId = $('input[name=serviceRadio]:checked').val();
	$('#calendar').fullCalendar('removeEvents');
	$.getJSON('/booking', {location: localId, provider: providerId}, function (bookings) {
		$.each(bookings, function (key, booking) {
			var events = {
				title: 'Ocupado',
				allDay: false,
				start: booking.start,
				end: booking.end,
			}
			$('#calendar').fullCalendar('renderEvent', events, true);
		});
	});
}