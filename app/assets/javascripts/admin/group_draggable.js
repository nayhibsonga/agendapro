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

  groupNewOrder(tbody);

  return false;
}

// Group Drag & Drop
function groupNewOrder (tbody) {
  var groups = new Array();
  $.each($(tbody).children(), function (key, tr) {
    var row_hash = {
      provider_group: $(tr).children("td:first").data('group'),
      order: key
    };
    groups.push(row_hash);
  });
  $.post(
    '/change_groups_order',
    {groups_order: groups},
    function (data) {
      $.each(data, function (key, result) {
        if (result.status != 'Ok') {
          $('.content-fix').prepend(
            '<div class="alert alert-danger alert-dismissable">' +
              '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
              'No se pudo guardar el cambio de orden de: ' + result.provider_group +
            '</div>'
          );
        };
      });
    }
  );
}
