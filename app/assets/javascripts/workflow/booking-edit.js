Date.isLeapYear = function (year) { 
    return (((year % 4 === 0) && (year % 100 !== 0)) || (year % 400 === 0)); 
};

Date.getDaysInMonth = function (year, month) {
    return [31, (Date.isLeapYear(year) ? 29 : 28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][month];
};

Date.prototype.isLeapYear = function () { 
    return Date.isLeapYear(this.getFullYear()); 
};

Date.prototype.getDaysInMonth = function () { 
    return Date.getDaysInMonth(this.getFullYear(), this.getMonth());
};

Date.prototype.addMonths = function (value) {
    var n = this.getDate();
    this.setDate(1);
    this.setMonth(this.getMonth() + value);
    this.setDate(Math.min(n, this.getDaysInMonth()));
    return this;
};

var now_date = new Date();
var after_date = now_date.addMonths(parseInt($("#after_booking").val()));

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


	$(document).on('calendarBuilded', function (e) {

		/*
			If there are no hours for this week,
			go to next week.
		*/


		
		if (e.date < after_date)
		{
			if($(".bloque-hora").size() == 0)
			{
				//Check that resulting date wouldn't be greater than after_date

				var resulting_date = new Date(e.date.getFullYear(), e.date.getMonth(), e.date.getDate() + 7)

				if(resulting_date < after_date)
				{
					$("#next").trigger("click");
					//reload_times =reload_times + 1;
					$("#next").attr("disabled", false);
				}
				else
				{
					myAlert.showAlert(
			            '<h3>No hay horarios disponibles</h3>' +
			            '<p>Lo sentimos, no hay más horarios disponibles después de la semana del ' + after_date.toLocaleDateString() + '.</p>'
			        );
				}
			}
		}
		else
		{

			var day = new Date(after_date.getFullYear(), after_date.getMonth(), after_date.getDate());

		  	var localId = $('#booking').data('booking').location_id;
			var selects = [];

			selects.push({
			  service: $('#booking').data('booking').service_id,
			  provider: $('#booking').data('booking').service_provider_id
			});


			var data;

			day_str = after_date.getFullYear() + "-" + (parseInt(after_date.getMonth())+1) + "-" + after_date.getDate();

			data = {local: localId, serviceStaff: JSON.stringify(selects), date: day_str, edit: true};

			if (calendar) {
				calendar.rebuild('/promotion_hours', data);
			}
			else {
				calendar = new PromoCalendar('/promotion_hours', data);
			}


			myAlert.showAlert(
	            '<h3>No hay horarios disponibles</h3>' +
	            '<p>Lo sentimos, no hay más horarios disponibles después de la semana del ' + after_date.toLocaleDateString() + '.</p>'
	        );
		}
	});


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