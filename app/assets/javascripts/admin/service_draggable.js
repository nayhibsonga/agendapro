
function drop (e) {
  if (e.stopPropagation) {
    e.stopPropagation();
  };
  if (e.preventDefault) {
    e.preventDefault();
  };

  var tbody = $(e.target).closest('tbody');
  if (dragElemente != this) {
    // Objects
    var origin = dragElemente;
    var destiny = this;
    var tmp = new Array();

    // Ordenando las filas
    $.each($(tbody).children(), function (pos, tr) {
      if (!Object.is(origin, tr)) {
        if (Object.is(destiny, tr)) {
          tmp.push(destiny);
          tmp.push(origin);
        } else{
          tmp.push(tr);
        };
      };
    });

    // Colocando las filas por orden
    $(tbody).empty();
    $.each(tmp, function (key, element) {
      $(tbody).append(element);
    });
  };

  serviceNewOrder(tbody);
  return false;
}

// Service Drag & Drop
function serviceNewOrder (tbody) {
  var services = new Array();
  $.each($(tbody).children(), function (key, tr) {
    var row_hash = {
      service: $(tr).children("td:first").data('service'),
      order: key
    };
    services.push(row_hash);
  });
  $.post(
    '/change_services_order',
    {services_order: services},
    function (data) {
      $.each(data, function (key, result) {
        if (result.status != 'Ok') {
          $('.content-fix').prepend(
            '<div class="alert alert-danger alert-dismissable">' +
              '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
              'No se pudo guardar el cambio de orden de: ' + result.service +
            '</div>'
          );
        };
      });
    }
  );
}
