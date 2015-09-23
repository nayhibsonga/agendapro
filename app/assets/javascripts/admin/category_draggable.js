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

  categoryNewOrder(tbody);

  return false;
}

// Category Drag & Drop
function categoryNewOrder (tbody) {
  var categories = new Array();
  $.each($(tbody).children(), function (key, tr) {
    var row_hash = {
      service_category: $(tr).children("td:first").data('category'),
      order: key
    };
    categories.push(row_hash);
  });
  $.post(
    '/change_categories_order',
    {category_order: categories},
    function (data) {
      $.each(data, function (key, result) {
        if (result.status != 'Ok') {
          $('.content-fix').prepend(
            '<div class="alert alert-danger alert-dismissable">' +
              '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
              'No se pudo guardar el cambio de orden de: ' + result.service_category +
            '</div>'
          );
        };
      });
    }
  );
}
