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

var actualDate = null;
var dateSelected = null;
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
    eventClick: function(event) {
      if ($.isNumeric(event.id)) {
        window.location.href = "/bookings/" + event.id;
      } else if (event.id.indexOf('b') >= 0) {
        window.location.href = "/provider_breaks/" + event.id.split('b')[1]
      };
    },
    dayClick: function(date, allDay, jsEvent, view) {
      var dates = {
        convert:function(d) {
          // Converts the date in d to a date-object. The input can be:
          //   a date object: returned without modification
          //  an array      : Interpreted as [year,month,day]. NOTE: month is 0-11.
          //   a number     : Interpreted as number of milliseconds
          //                  since 1 Jan 1970 (a timestamp)
          //   a string     : Any format supported by the javascript engine, like
          //                  "YYYY/MM/DD", "MM/DD/YYYY", "Jan 31 2009" etc.
          //  an object     : Interpreted as an object with year, month and date
          //                  attributes.  **NOTE** month is 0-11.
          return (
            d.constructor === Date ? d :
            d.constructor === Array ? new Date(d[0],d[1],d[2]) :
            d.constructor === Number ? new Date(d) :
            d.constructor === String ? new Date(d) :
            typeof d === "object" ? new Date(d.year,d.month,d.date) :
            NaN
          );
        },
        compare:function(a,b) {
          // Compare two dates (could be of any type supported by the convert
          // function above) and returns:
          //  -1 : if a < b
          //   0 : if a = b
          //   1 : if a > b
          // NaN : if a or b is an illegal date
          // NOTE: The code inside isFinite does an assignment (=).
          return (
            isFinite(a=this.convert(a).valueOf()) &&
            isFinite(b=this.convert(b).valueOf()) ?
            (a>b)-(a<b) :
            NaN
          );
        }
      }
      if (dateSelected != null && dates.compare(date, dateSelected) == 0) {
        var arrDate = date.toString().split(" ");
        var stringDate = arrDate[0] + " " + arrDate[1] + " " + arrDate[2] + " " + arrDate[3] + " " + arrDate[4];
        var bookHref = "/bookings/new?" + $.param({
          location: $('#locals-selector').val(),
          date: stringDate,
          provider: providerId
        });
        $('#addModal .btn-green').attr('href', bookHref);
        var breakHref = "/provider_breaks/new?" + $.param({
          location: $('#locals-selector').val(),
          date: stringDate,
          provider: providerId
        });
        $('#addModal .btn-grey').attr('href', breakHref);
        $('#addModal').modal('toggle');
      } else {
        $('td.fc-widget-content.active').children().first().html("&nbsp;");
        $('td.fc-widget-content.active').removeClass('active');
        $(jsEvent.currentTarget).addClass('active');
        $(jsEvent.currentTarget).children().first().html('<i class="fa fa-plus fa-lg"></i>');
        dateSelected = date;
      };
    },
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

  actualDate = actualDate || $('#calendar').fullCalendar('getDate');
  picker.set('select', actualDate);
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
    var providerId = parseInt($('#providers-selector').val());
    if (providerId > 0) {
      loadProviderTime(providerId);
    };
  });

  $('#add').click(function () {
    var bookHref = "/bookings/new?" + $.param({
      location: $('#locals-selector').val(),
      provider: $('#providers-selector').val()
    });
    $('#addModal .btn-green').attr('href', bookHref);
    var breakHref = "/provider_breaks/new?" + $.param({
      location: $('#locals-selector').val(),
      provider: $('#providers-selector').val()
    });
    $('#addModal .btn-grey').attr('href', breakHref);
    $('#addModal').modal('toggle');
  });

  picker = datepicker('#today', {
    onSet: function (context) {
      if (context.select) {
        var val = $('#today').val();
        $('#today').text(val);
        $('#calendar').fullCalendar('gotoDate', new Date(context.select));
        providerId = parseInt($('#providers-selector').val());
        if (providerId > 0) {
          actualDate = $('#calendar').fullCalendar('getDate');
          loadProviderEvents(providerId);
        };
      };
    }
  });
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
