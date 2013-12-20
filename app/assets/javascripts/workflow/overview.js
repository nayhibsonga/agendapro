function loadOverview() {
  $('#services-link').removeClass('active');
  $('#overview-link').addClass('active');
  $('#services').css("display", "none");
  $('#overview').css("display", "block");
  $('#schedule').show();
}

function loadServices() {
  if ($('[name="localRadio"]').is(':checked')) {
    var localId = $('input[name=localRadio]:checked').val()
    alert( localId );
    $('#overview-link').removeClass('active');
    $('#services-link').addClass('active');
    $('#overview').css("display", "none");
    $('#services').css("display", "block");
    $('#schedule').hide();
  }
  else {
    alert("Seleccione un local");
  }
}

function loadSchedule(id) {
  $('.schedule-body').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
  $.getJSON('/schedule', {local: id}, function (schedule) {
    $('.schedule-body').html('');
    $('.schedule-body').append('<ul class="list-unstyled"></ul>');
    $.each(schedule, function (day, hours) {
      $('.list-unstyled').append('<li id="' + day + '"><b>' + day + ' </b></li>');
      $.each(hours, function (pos, hour) {
        $('#' + day).append(getHour(hour.open) + '-' + getHour(hour.close) + ' ');
      })
    })
  });
}

function getHour(str) {
  var index = str.indexOf('T'); //2000-1-1T08:00:00Z
  str = str.substring(index + 1, index + 6); //08:00
  return str;
}

$(function() {
  $('[name="localRadio"]').on('click', function(event) {
    var id = event.target.getAttribute('value');
    loadSchedule(id);
  });

  $('#overview-link').click(function (event) {
    loadOverview();
    event.preventDefault(); // Prevent link from following its href
  });

  $('#services-link').click(function (event) {
    loadServices();
    event.preventDefault(); // Prevent link from following its href
  });

  $('#schedule').click(function (event) {
    loadServices();
    event.preventDefault(); // Prevent link from following its href
  });
});