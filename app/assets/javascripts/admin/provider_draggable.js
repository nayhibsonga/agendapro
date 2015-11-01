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
      providerNewOrder(tbody);
    }
  });
});

// Service Drag & Drop
function providerNewOrder (tbody) {
  var providers = new Array();
  $.each($(tbody).children(), function (key, tr) {
    var row_hash = {
      provider: $(tr).children("td:first").data('provider'),
      order: key
    };
    providers.push(row_hash);
  });
  $.post(
    '/change_providers_order',
    {providers_order: providers},
    function (data) {
      $.each(data, function (key, result) {
        if (result.status != 'Ok') {
          $('.content-fix').prepend(
            '<div class="alert alert-danger alert-dismissable">' +
              '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
              'No se pudo guardar el cambio de orden de: ' + result.provider +
            '</div>'
          );
        };
      });
    }
  );
}
