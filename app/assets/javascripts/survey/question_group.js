$(window).load(function(){
  $('.content_questions').sortable({
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
      //categoryNewOrder(tbody);
    }
  });
});
$(document).on('click','#delete',function(e){
  $(this).parents(".well").remove();
})
function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")

  $('.content_questions').append(content.replace(regexp, new_id));
}
