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
      //var tbody = $(event.target);
      categoryNewOrder();
    }
  });
});
function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).parents(".well").hide();
}
function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  var max = 0;
  $(".content_questions .well").each(function(e, target){
    max = e;
  })
  if(max >= 4){
    swal({
      title: "Máximo 5 preguntas.",
      type: "error"
    });
  }else{
    $('.content_questions').append(content.replace(regexp, new_id));
  }
}
// Category Drag & Drop
function categoryNewOrder (tbody) {
  var categories = new Array();
  $('body .well').each(function(e, target){
    $(target).children('.order').val(e);
  });
}
