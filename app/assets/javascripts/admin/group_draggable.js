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
      groupNewOrder(tbody);
    }
  });
});

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
