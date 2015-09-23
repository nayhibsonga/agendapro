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
        $(this).width($originals.eq(index).width());
      });
      return $helper;
    },
    revert: 300,
    update: function (event, ui) {
      var tbody = $(event.target);
      categoryNewOrder(tbody);
    }
  });
});

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
