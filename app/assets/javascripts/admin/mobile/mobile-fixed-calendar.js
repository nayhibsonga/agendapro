function loadProviders () {
  if (parseInt($('#locals-selector').val()) > 0) {
    var localId = parseInt($('#locals-selector').val());
    $.getJSON('/location_services', {location: localId}, function (services) {
      $.getJSON('/local_providers', {location: localId}, function (providersArray) {
        $('#providers-selector').empty();
        if (providersArray.length > 0) {
          $.each(providersArray, function (key, provider) {
            $('#providers-selector').append('<option name="providerRadio" value="'+provider.id+'">'+provider.public_name+'</option>');
          });
          providerId = parseInt($('#providers-selector').val());
          loadProviderTime(providerId);
        };
      });
    });
  };
}

function loadProviderTime (providerId) {
  var extended_schedule_bool = $('#calendar-data').data('extended-schedule');
  if (extended_schedule_bool) {
    var extended_min_hour = $('#calendar-data').data('extended-min-hour');
    var extended_max_hour = $('#calendar-data').data('extended-max-hour');
    loadWeekCalendar(extended_min_hour, extended_max_hour, providerId);
  }
  else {
    var min_hour = $('#locals-selector').find(':selected').data('minhour');
    var max_hour = $('#locals-selector').find(':selected').data('maxhour');
    loadWeekCalendar(min_hour, max_hour, providerId);
  }
}

function loadProviderEvents(providerId) {
  $('.btn-group > button').addClass('disabled');
  $('#loader').removeClass('hidden');
  var localId = parseInt($('#locals-selector').val());
  var start = $('#calendar').fullCalendar('getView').start;
  var end = $('#calendar').fullCalendar('getView').end;
  var startParam = start.getFullYear() + '-' + (start.getMonth() + 1) + '-' + start.getDate();
  var endParam = end.getFullYear() + '-' + (end.getMonth() + 1) + '-' + end.getDate();
  $('#calendar').fullCalendar('removeEvents');
  $.getJSON('/booking',
    {
      location: localId,
      provider: providerId,
      start: startParam,
      end: endParam
    }, function (events_list) {
      $('#calendar').fullCalendar('addEventSource', events_list);
      $('.btn-group > button').removeClass('disabled');
      $('#loader').addClass('hidden');
  });
  return false;
}

function loadWeekCalendar (startTime, endTime, providerId) {
  //Default values
  startTime = startTime || 0;
  endTime = endTime || 24;
  var duration = $('#calendar-data').data('calendar-duration');

  $('#calendar').fullCalendar('removeEvents');
  $('#calendar').empty();
  $('#calendar').fullCalendar({
    header: false,
    resources: [],
    firstDay: 1,  //Lunes
    defaultView: 'agendaDay',
    allDaySlot: false,
    axisFormat: 'HH:mm',
    timeFormat: 'HH:mm{ - HH:mm}',
    minTime: startTime,
    maxTime: endTime,
    defaultEventMinutes: duration,
    slotMinutes: duration,
    height: 10000
  });

  loadProviderEvents(providerId);
}

var picker;
$(function() {
  if (parseInt($('#locals-selector').val()) > 0) {
    loadProviders();
  };

  $('#locals-selector').change(function() {
    if (parseInt($('#locals-selector').val()) > 0) {
      loadProviders();
    };
  });
  $('#providers-selector').change(function() {
    providerId = parseInt($('#providers-selector').val());
    if (providerId > 0) {
      loadProviderTime(providerId);
    };
  });

  var datepicker = $('#today').pickadate({
    monthsFull: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthsShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    weekdaysFull: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    weekdaysShort: ['Dom', 'Lun', 'Mar', 'Mier', 'Jue', 'vie', 'Sáb'],
    today: 'Hoy',
    clear: '',
    firstDay: 1,
    format: 'ddd dd/mm/yyyy',
    formatSubmit: 'yyyy/mm/dd',
    hiddenName: true,
    onSet: function (context) {
      if (context.select) {
        var val = $('#today').val();
        $('#today').text(val);
        $('#calendar').fullCalendar('gotoDate', new Date(context.select));
        providerId = parseInt($('#providers-selector').val());
        if (providerId > 0) {
          loadProviderEvents(providerId);
        };
      };
    }
  });
  picker = datepicker.pickadate('picker');
  $('#prev').click(function() {
    $('#calendar').fullCalendar('prev');
    var d = $('#calendar').fullCalendar('getDate');
    picker.set('select', d);
  });
  $('#next').click(function() {
    $('#calendar').fullCalendar('next');
    var d = $('#calendar').fullCalendar('getDate');
    picker.set('select', d);
  });
});
