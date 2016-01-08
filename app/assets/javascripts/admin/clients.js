function createdComment() {
  return false;
}

function startEditComment(id) {
  var comment = $('#comment'+id).html().replace(/<br\s*[\/]?>/gi, "\n");
  $('#comment'+id).html('<textarea class="form-control" id="client_comment_comment'+id+'" rows="5">' + comment+ '</textarea>');
  $('#edit_button'+id).html('<i class="fa fa-check"></i> Guardar').removeClass('btn-orange').addClass('btn-white');
  $('#destroy_button'+id).html('<i class="fa fa-times"></i> Cancelar');
  $('#edit_button'+id).unbind('click');
  $('#destroy_button'+id).unbind('click');
  $('#edit_button'+id).click( function() {
    saveEditComment(id);
    return false;
  });
  $('#destroy_button'+id).click( function() {
    cancelEditComment(id);
    return false;
  });
}

function saveEditComment(id) {
  saveComment("PATCH",$('#client_comment_client_id').val(),{"id": id, "client_id": $('#client_comment_client_id').val(), "comment": $('#client_comment_comment'+id).val() });
}

function cancelEditComment(id) {
  var comment = $('#client_comment_comment'+id).html().replace(/\n/g, "<br />");
  $('#comment'+id).html(comment);
  $('#edit_button'+id).html('<i class="fa fa-pencil"></i> Editar').removeClass('btn-white').addClass('btn-orange');;
  $('#destroy_button'+id).html('<i class="fa fa-trash-o"></i> Eliminar');
  $('#edit_button'+id).unbind('click');
  $('#destroy_button'+id).unbind('click');
  $('#edit_button'+id).click( function() {
    startEditComment(id);
    return false;
  });
  $('#destroy_button'+id).click( function() {
    deleteComment(id);
    return false;
  });
}

function deleteComment(id) {
  swal({
    title: "¿Estás seguro de eliminar el Comentario seleccionado?",
    type: "warning"
  },
  function (isConfirm) {
    if (isConfirm) {  
      saveComment("DELETE",$('#client_comment_client_id').val(),{"id": id });
    }
  });
  return false;
}

function getNewClientComment() {
  var json = { "client_id": $('#client_comment_client_id').val(), "comment": $('#client_comment_comment').val() };
  return json;
}

function getEditClientComment() {
  var json = { "client_id": $('#client_comment_client_id').val(), "comment": $('#client_comment_comment').val() };
  return json;
}

function createComment() {
  commentJSON = getNewClientComment();
  saveComment('POST',$('#client_comment_client_id').val(),commentJSON);
}

function saveComment(typeURL, clientId, json) {
  $.ajax({
    type: typeURL,
    url: '/clients/'+ clientId +'/comments.json',
    data: { "client_comment": json },
    dataType: 'json',
    success: function(){
      document.location.href = '/clients/'+clientId+'/edit/';
    },
    error: function(xhr){
      var errors = $.parseJSON(xhr.responseText).errors;
      var errores = '';
      for (i in errors) {
        errores += '*' + errors[i];
      }
      swal({
        title: "Error",
        text: "Se produjeron los siguientes errores:\n" + errores,
        type: "error"
      });
    }
  });
}

function setAge() {

  if ($('#client_birth_day').val() != '' && $('#client_birth_month').val() != '' && $('#client_birth_year').val() != '')
  {
    var day = $('#client_birth_day').val();
    var month = $('#client_birth_month').val() - 1;
    var year = $('#client_birth_year').val();

    var date1 = new Date(year,month,day);
    //hoy
    var date2 = new Date();

    var milli = date2 - date1;
    var milliPerYear = 1000 * 60 * 60 * 24 * 365.26;

    var yearsApart = milli/milliPerYear;
    $('#client_age').val(yearsApart | 0);

  }
  return false;
}

$(function() {
  $('#new_comment_button').click(function() {
    createComment();
    return false;
  });
  $("[id^='destroy_button']").click(function(event) {
    deleteComment(event.target.id.split('destroy_button')[1]);
    return false;
  });
  $("[id^='edit_button']").click(function(event) {
    startEditComment(event.target.id.split('edit_button')[1]);
    return false;
  });
  setAge();
  $('#client_birth_day').change(function() {
    setAge();
  });
  $('#client_birth_month').change(function() {
    setAge();
  });
  $('#client_birth_year').change(function() {
    setAge();
  });

  $('#addFileBtn').on('click', function(){
    $('#fileUploadModal').modal('show');
  });

  $('.viewFileBtn').on('click', function(){

    var client_file_id = $(this).attr('client_file_id');

    $.ajax({
      url: '/client_files/' + client_file_id,
      method: 'get',
      dataType: 'json',
      error: function(response){
        swal({
          title: "Error",
          text: "Se produjo un error",
          type: "error"
        });
      },
      success: function(response){
        client_file = response[0];
        public_url = response[1];
        is_image = response[2];
        $('#view_file_name').html(client_file.name);
        $('#view_file_description').html(client_file.description);
        $('#view_file_link').empty();
        $('#view_file_link').append('<a style="margin-top: 4px;" href="' + public_url + '">Descargar</a>');
        if(is_image)
        {
          $('#view_file_preview').html('<image src="' + public_url + '" width="200px;" height="200px;" />');
          $('#view_file_preview_div').show();
        }
        else
        {
          $('#view_file_preview').empty();
          $('#view_file_preview_div').hide();
        }
        $('#viewFileModal').modal('show');
      }
    })

  });

  $(".file-delete").on("ajax:success", function(e, data, status, xhr){
    var file_id = data.id;
    $('.file-row[file_id="' + file_id + '"]').remove();
    swal({
        title: "Éxito",
        text: "Archivo eliminado correctamente..",
        type: "success"
    });
  }).on("ajax:error", function(e, xhr, status, error){
    console.log(xhr.responseText)
    swal({
      title: "Error",
      text: "Se produjo un error",
      type: "error"
    });
  });

  $(".attribute_datepicker").datepicker({
    dateFormat: 'dd/mm/yy',
    autoSize: true,
    firstDay: 1,
    changeMonth: true,
    changeYear: true,
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
        monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
        prevText: 'Atrás',
        nextText: 'Adelante',
        dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
        dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
        dayNamesMin: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
        today: 'Hoy',
        clear: ''
  });

});
