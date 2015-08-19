var calendar;
var selected = false;

function loadCalendar()
{
	var selects = [];

	date = Date.new;

	selects.push({
	  service: $('#booking').data('booking').service_id,
	  provider: $('#booking').data('booking').service_provider_id
	});

	var data = {
	  date: date,
	  serviceStaff: JSON.stringify(selects),
	  local: $('#booking').data('booking').location_id,
	  edit: true
	}

	console.log(data);

	calendar = new PromoCalendar('/promotion_hours', data);

	$(document).on('hourClick', function (e) {

	  
	    bookSummary = bookSummaries[e.index];
	    bookDetails = bookSummary.bookings[0];

	    bookDetailsStart = bookDetails.start.split("T")[1].split(":")[0] + ':' + bookDetails.start.split("T")[1].split(":")[1];
	    bookDetailsEnd = bookDetails.end.split("T")[1].split(":")[0] + ':' + bookDetails.end.split("T")[1].split(":")[1];


	    addBooking(e);

	    selected = true;

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

	});
}

$("#datepicker").datepicker({
    dateFormat: 'dd-mm-yy',
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
    dateFormat: 'yy-mm-dd',
    onSelect: function(newDate){

      var selects = [];

      selects.push({
        service: $('#booking').data('booking').service_id,
        provider: $('#booking').data('booking').service_provider_id
      });

      var data = {
        date: newDate,
        serviceStaff: JSON.stringify(selects),
        local: $('#booking').data('booking').location_id,
        edit: true
      }

      console.log(data);

      calendar.rebuild('/promotion_hours', data);

      $(document).on('hourClick', function (e) {

        
			bookSummary = bookSummaries[e.index];
			bookDetails = bookSummary.bookings[0];

			bookDetailsStart = bookDetails.start.split("T")[1].split(":")[0] + ':' + bookDetails.start.split("T")[1].split(":")[1];
			bookDetailsEnd = bookDetails.end.split("T")[1].split(":")[0] + ':' + bookDetails.end.split("T")[1].split(":")[1];

			addBooking(e);

			selected = true;

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

      });

    }
});

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

$(document.body).on('click', '.date-span', function(e) {
  $(e.currentTarget).find('input').datepicker('show');
});

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