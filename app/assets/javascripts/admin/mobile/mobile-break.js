function saveBreak (typeURL, booking_id) {
  var date = $('#date').val().split('-');
  var breakJSON = {
    'start': date[2] + '/' + date[1] + '/' + date[0] + 'T' + $('#start').val() + ':00Z',
    'end': date[2] + '/' + date[1] + '/' + date[0] + 'T' + $('#end').val() + ':00Z',
    "service_provider_id": [$('#provider_break_service_provider_id').val()],
    "name": $('#provider_break_name').val(),
    "local": $('#provider_break_location').val(),
    "repeat": "never"
    };
  $.ajax({
    type: typeURL,
    url: '/provider_breaks' + booking_id + '.json',
    data: { "provider_break": breakJSON },
    dataType: 'json',
    success: function(booking){
      window.location.href = "/bookings/"
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors[0].errors;
      var errores = 'Error\n';
      for (i in errors) {
        errores += '*' + errors[i] + '\n';
      }
      $('button[type="submit"]').removeClass('disabled');
      $('button[type="submit"]').html('Guardar');
      swal({
        title: "Error",
        text: "Se produjeron los siguientes problemas:\n" + errores,
        type: "error"
      });
    }
  });
}

$(function () {
  $('button[type="submit"]').click(function (event) {
    event.preventDefault();
    $(this).addClass('disabled');
    $(this).html($(this).data('loading'));
    var booking = '';
    if ($(this).data('id')) {
      booking = '/' + $(this).data('id');
    };
    var url = $(this).data('url');
    saveBreak(url, booking);
  });
});
