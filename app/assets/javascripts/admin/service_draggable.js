$(function () {
  $('tbody').sortable({
    axis: 'y',
    handle: '.fa-bars',
    helper: function(e, tr) {
      var $originals = tr.children();
      var $helper = tr.clone();
      $helper.children().each(function(index)
      {
        // Set helper cell sizes to match the original sizes
        $(this).width($originals.eq(index).outerWidth());
      });
      return $helper;
    },
    revert: 300,
    update: function (event, ui) {
      var tbody = $(event.target);
      serviceNewOrder(tbody);
    }
  });
});

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
