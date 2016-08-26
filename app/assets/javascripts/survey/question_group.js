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
    //$('.content_questions').append(content.replace(regexp, new_id));
    $('#modalQuestion .modal-body').html(content.replace(regexp, new_id));
  }
  $('#modalQuestion').modal()
}
$('#modalQuestion').on('hidden.bs.modal', function () {
  $('#modalQuestion .modal-body').html("");
})
function editQuestion(e){
  content = $(e).parent().parent().children(".hidden_fields").html();
  temp = $(e).parent().parent();
  $('#modalEditQuestion .modal-body').html(content);
  $('#modalEditQuestion').modal();
}
$(document).on("click","#acceptModalEdit",function(e){
  var title = "";
  var construct = $(document).find('#modalEditQuestion .modal-body');

  construct.find("input,textarea,select").each(function(index,value){
    console.log($(value).val());
  })
  /*
  $(temp).children(".title").children("h4").html(title)
  $(temp).children(".hidden_fields").html(construct.html())*/
  console.log(construct.html());
})
$("#acceptModal").click(function(e){
  var title = "";
  var construct = $('#modalQuestion .modal-body');
  construct.find("input,textarea,select").each(function(index,value){
    if ($(value).attr("dataQuestion") == "question"){
      title = $(value).val()
    }
  })
  $(".content_questions").append('<div class="question">'+
                                  '<div class="title"><h4>'+title+'</h4></div>'+
                                    '<div class="hidden_fields">'+
                                      construct.html()+
                                    '</div>'+
                                  '</div>'+
                                  '</div>'
                                )
  $("#messageEmpty").hide();
})
$("#cancelModal").click(function(e){

})
// Category Drag & Drop
function categoryNewOrder (tbody) {
  var categories = new Array();
  $('body .well').each(function(e, target){
    $(target).children('.order').val(e);
  });
}
