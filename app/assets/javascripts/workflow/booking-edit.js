function loadCalendar () {
	var data = {
		provider: $('#booking').data('booking').service_provider_id,
		local: $('#booking').data('booking').location_id,
		service: $('#booking').data('booking').service_id
	}
	var calendar = new Calendar('/get_available_time.json', data);
	
	$(document).on('hourClick', function (e) {
		addBooking(e);
	});

	$(function () {
		$('#prev').click(function () {
			selected = false;
		});
		$('#next').click(function () {
			selected = false;
		});
		$('#today').click(function () {
			selected = false;
		});
	});
}

var selected = false;

function addBooking (booking) {
	var today = new Date();
	today.setHours(23, 59, 59, 999);
	if (today < booking.objectDate) {
		selected = true;
		$('#start').val(generateDate(booking.date, booking.start));
		$('#end').val(generateDate(booking.date, booking.end));
	}
	else {
		selected = false;
		$('.hora-activo').addClass('hora-disponible').removeClass('hora-activo');
		myAlert.showAlert(
	      '<h3>Horario Inválido</h3>' +
	      '<p>La fecha/hora elegida es anterior a la fecha/hora actual o no cumple el tiempo mínimo requerido para agendar.</p>'
	    );
	}
}

function generateDate(date, time) {
	var month = date.substring(0, date.indexOf('-'));
	var day = date.substring(date.indexOf('-') + 1, date.lastIndexOf('-'));
	var year = date.substring(date.lastIndexOf('-') + 1);

	time += ':00';

	return year + '-' + month + '-' + day + ' ' + time;
}

var myAlert;
$(function () {
	myAlert  = new Alert('.main');
	loadCalendar();

	$('#edit_form').submit(function (event) {
		if (!selected) {
	    	event.preventDefault();
			myAlert.showAlert(
		      '<h3>Selecciona un Horario</h3>' +
		      '<p>Debes elegir un horario antes de poder continuar.</p>'
		    );
		}
  	});
});