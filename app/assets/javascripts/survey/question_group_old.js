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
  content = $(e).parent().parent().children(".hidden_fields");
  temp = $(e).parent().parent();
  var $orginal = $('#modalEditQuestion .modal-body');
  content.find('input').each(function(index, item) {
    var dataQuestion = $(item).attr("dataQuestion");
    if(dataQuestion=="attribute"){
      $orginal.find("select[dataQuestion='attribute']").val($(item).val())
    }else if (dataQuestion=="type"){
      $orginal.find("select[dataQuestion='type']").val($(item).val())
    }else if (dataQuestion=="question"){
      $orginal.find("input[dataQuestion='question']").val($(item).val())
    }else if (dataQuestion=="description"){
      $orginal.find("textarea[dataQuestion='description']").val($(item).val())
    }
    console.log(item)
  });
  //$('#modalEditQuestion .modal-body').html(content);
  $('#modalEditQuestion').modal();
}
$(document).on("click","#acceptModalEdit",function(e){
  var title = "";
  var construct = $(document).find('#modalEditQuestion .modal-body');
  var $orginal = $('#modalEditQuestion .modal-body');
  var $cloned = $orginal.clone();

  $orginal.find('select,input,textarea').each(function(index, item) {
       //set new select to value of old select
    var dataQuestion = $(item).attr("dataQuestion");
    if(dataQuestion=="attribute"){
      $(temp).find("input[dataQuestion='attribute']").val($(item).val())
    }else if (dataQuestion=="type"){
      $(temp).find("input[dataQuestion='type']").val($(item).val())
    }else if (dataQuestion=="question"){
      $(temp).find("input[dataQuestion='question']").val($(item).val())
      console.log("question")
    }else if (dataQuestion=="description"){
      $(temp).find("input[dataQuestion='description']").val($(item).val())
    }

  });
/*
  $(temp).children(".title").children("h4").html(title)
  $(temp).children(".hidden_fields").children("div").remove();
  $cloned.appendTo($(temp).children(".hidden_fields"));
  $('#modalEditQuestion').modal('hide');
  console.log(construct.clone(true).off());*/
})

$("#acceptModal").click(function(e){
  var title = "";
  var construct = $('#modalQuestion .modal-body');
  var inputs = [];
  construct.find("input,textarea,select").each(function(index,value){
    var dataQuestion = $(value).attr("dataQuestion");
    var name = $(value).attr("name");
    var value = $(value).attr("value");
    var id = $(value).attr("id");
    if (dataQuestion == "question"){
      title = value
      $(value).attr("dataQuestion")
    }
    inputs.push("<input name='"+name+"' id='"+id+"' value='"+value+"' dataQuestion='"+dataQuestion+"' >");
  })
  $(".content_questions").append('<div class="question col-md-12">'+
                                  '<div class="title"><h4>'+title+'</h4></div>'+
                                    '<div class="hidden_fields">'+
                                       inputs +
                                    '</div>'+
                                  '<div class="col-md-offset-10 col-md-2 inline-right"><%= link_to_remove_fields "", u %><a href="#" class="btn btn-orange" onclick="editQuestion(this)" style="margin-left:10px;"><i class="fa fa-pencil" aria-hidden="true"></i></a></div></div>'
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
