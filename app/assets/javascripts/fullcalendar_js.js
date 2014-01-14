
//= require admin/fullcalendar.min
//= require admin/admin-calendar

$(function() {
  
  loadProviders();

  $('#calendar').fullCalendar({
        dayClick: function() {
        	alert('a day has been clicked!');
    	},
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
	    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
    })
});