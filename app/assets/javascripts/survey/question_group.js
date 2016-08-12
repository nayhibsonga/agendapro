$(function () {
  $('.well').sortable({
    axis: 'y',
    handle: '.content_questions',
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
      //categoryNewOrder(tbody);
    }
  });
});
$('#add_question').click(function(e){
  $(".content_questions").append($(".partial").html())
})
