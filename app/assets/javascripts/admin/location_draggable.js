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

  locationNewOrder(tbody);
  return false;
}

// Category Drag & Drop
function locationNewOrder (tbody) {
  var locations = new Array();
  $.each($(tbody).children(), function (key, tr) {
    var row_hash = {
      location: $(tr).children("td:first").data('location'),
      order: key
    };
    locations.push(row_hash);
  });
  $.post(
    '/change_location_order',
    {location_order: locations},
    function (data) {
      $.each(data, function (key, result) {
        if (result.status != 'Ok') {
          $('.content-fix').prepend(
            '<div class="alert alert-danger alert-dismissable">' +
              '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
              'No se pudo guardar el cambio de orden de: ' + result.location +
            '</div>'
          );
        };
      });
    }
  );
}
