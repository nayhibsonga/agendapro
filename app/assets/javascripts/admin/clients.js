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

  $('#addFileBtn').on('click', function(){
    clearValidations("#file");
    clearValidations("#file_name");
    clearValidations("#file_description");
    clearValidations("#new_folder_name");
    clearValidations("#folderSelect");
    $('#fileUploadModal').modal('show');
  });

  $('#addFolderBtn').on('click', function(){
    clearValidations("#client_folder_name");
    $('#addFolderModal').modal('show');
  });

  $('.addFolderFileBtn').on('click', function(){
    clearValidations("#file");
    clearValidations("#file_name");
    clearValidations("#file_description");
    clearValidations("#new_folder_name");
    clearValidations("#folderSelect");
    $('#fileUploadModal #folderSelect').val($(this).attr("folder_name"));
    $('#fileUploadModal').modal('show');
  });

  $('.renameFolderBtn').on('click', function(e){
    clearValidations("#rename_folder_name");
    $('#old_folder_name').val($(this).attr("folder_name"));
    $('#renameFolderModal').modal('show');
  });

  $('.moveFileBtn').on('click', function(e){
    $('#move_client_file_id').val($(this).attr("client_file_id"));
    $('#moveFileModal').modal('show');
  });

  $('.editFileBtn').on('click', function(){
    clearValidations("#edit_file_name");
    clearValidations("#edit_file_description");
    clearValidations("#edit_new_folder_name");
    clearValidations("#editFolderSelect");
    $('#edit_client_file_id').val($(this).attr("client_file_id"));
    $('#edit_file_name').val($(this).attr("client_file_name"));
    $('#edit_file_description').val($(this).attr("client_file_description"));
    $('#editFolderSelect').val($(this).attr("client_file_folder"));
    $('#editFileModal').modal('show');
  });

  $('.deleteFolderBtn').on('click', function(e){

    $('#delete_folder_name').val("");
    var folder_name = $(this).attr("folder_name");

    swal({
      title: "¿Estás seguro que deseas eliminar la carpeta? Se eliminarán todos los archivos que contiene.",
      type: "warning"
    },
    function (isConfirm) {
      $('#delete_folder_name').val(folder_name);
      $('#client_delete_folder_form').submit();
    });

  });

  $('#folders_accordion .panel-collapse').on('hide.bs.collapse', function (e) {
      console.log('Event fired on #' + e.currentTarget.id);
      var folder_id = e.currentTarget.id.split("_")[2];
      $('#folder_heading_' + folder_id).find('.folder-icons-closed').show();
      $('#folder_heading_' + folder_id).find('.folder-icons-open').hide();
  });

  $('#folders_accordion .panel-collapse').on('show.bs.collapse', function (e) {
      console.log('Event fired on #' + e.currentTarget.id);
      var folder_id = e.currentTarget.id.split("_")[2];
      $('#folder_heading_' + folder_id).find('.folder-icons-closed').hide();
      $('#folder_heading_' + folder_id).find('.folder-icons-open').show();
  });

});
