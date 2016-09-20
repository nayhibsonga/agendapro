$(function () {

  $('#toggleMerge').on('click', function(){
    if($(this).hasClass("inactive"))
    {
      $(this).removeClass("inactive");
      $(this).addClass("active");
      $('.combination-td').show();
      $('.combination-checkbox').prop('checked', false);
      $('.regular-btn').hide();
    }
    else
    {
      $(this).removeClass("active");
      $(this).addClass("inactive");
      $('.combination-td').hide();
      $('.combination-checkbox').prop('checked', false);
      $('.regular-btn').show();
      $('.merge-btn').hide();
      $('.combination-explanation').hide();
    }
  });

  $('.combination-checkbox').on('change', function(){
    var client_id = $(this).attr("client_id");
    if($(this).is(':checked'))
    {
      $('.merge-btn[client_id="' + client_id + '"]').show();
      $('.combination-explanation[client_id="' + client_id + '"]').show();
    }
    else
    {
      $('.merge-btn[client_id="' + client_id + '"]').hide();
      $('.combination-explanation[client_id="' + client_id + '"]').hide();
    }
  });

  $('.merge-btn').on('click', function(){
    var target_id = $(this).attr("client_id");
    var origin_ids = [];
    $('.combination-checkbox:checked').each(function(){
      if($(this).attr("client_id") != target_id)
      {
        origin_ids.push($(this).attr("client_id"));
      }
    });

    if(origin_ids.length < 1)
    {
      swal({
        title: "No se eligieron clientes",
        text: "Elige al menos un cliente a combinar con éste.",
        type: "warning"
      });
      return false;
    }

    swal({
      title: "¿Estás seguro que quieres combinar los clientes?",
      text: "Las reservas, pagos, archivos y otros elementos de los clientes seleccionados serán traspasados a este cliente. Los datos personales del cliente se mantendrán intactos, y los otros clientes se eliminarán.",
      type: "warning",
      showCancelButton: true
    },
    function(isConfirm) {
      if (isConfirm) {
        $.ajax({
          url: '/merge_clients',
          method: 'post',
          data: {target_id: target_id, origin_ids: origin_ids},
          dataType: 'json',
          error: function(response){
            swal({
              title: "Error",
              text: "Ocurrió un error al combinar clientes.",
              type: "error"
            });
          },
          success: function(response){
            triggerSuccess("Clientes combinados exitosamente.");
            window.location.reload();
          }
        });
      }
    });

  });

  $('[data-toggle="tooltip"]').tooltip();

  createDatepicker("#birth_from_display", {
    dateFormat: 'dd M',
    altField: '#birth_from',
    onSelect: function(newDate){
      nextDate = $("#birth_from_display").datepicker("getDate");
      nextDate.setFullYear(nextDate.getFullYear() + 1);
      $('#birth_to_display').datepicker("option", {
        minDate: newDate,
        maxDate: nextDate
      });
    }
  });
  createDatepicker("#birth_to_display", {
    dateFormat: 'dd M',
    altField: '#birth_to'
  });
  createDatepicker("#range_from_display", {
    dateFormat: 'dd M yy',
    altField: '#range_from',
    onSelect: function(newDate){
      nextDate = $("#range_from_display").datepicker("getDate");
      nextDate.setFullYear(nextDate.getFullYear() + 1);
      $('#range_to_display').datepicker("option", {
        minDate: newDate,
        maxDate: nextDate
      });
    }
  });
  createDatepicker("#range_to_display", {
    dateFormat: 'dd M yy',
    altField: '#range_to'
  });

  $('#search_btn').click(function (e) {
    var data = $('#search_bar').val();
    $('#search').val(data);
    $('#client_filter').submit();
  });

  $('#file').change( function () {
    if ($('#file').val()) {
      $('#import_button').removeAttr("disabled");
    }
    else {
      $('#import_button').attr("disabled", "disabled");
    }
  });

  $('#import_button').on('click', function(e){
    if(!checkFile()) {
      e.preventDefault();
    }
  });

  $('#file-group').show();
  $('.client_can_book').change(function(event) {
    $('#client_can_book'+event.target.value).hide();
    $('#loader'+event.target.value).removeClass('hidden');
    $.ajax({
      type: 'PATCH',
      url: '/clients/'+event.target.value+'.json',
      data: { "client": { "can_book": $('#client_can_book'+event.target.value).prop('checked') } },
      dataType: 'json',
      success: function(provider_break){
        $('#loader'+event.target.value).addClass('hidden');
        $('#client_can_book'+event.target.value).show();
      },
      error: function(xhr){
        $('#loader'+event.target.value).addClass('hidden');
        $('#client_can_book'+event.target.value).prop('checked', !$('#client_can_book'+event.target.value).prop('checked'));
        $(event.target.id).show();
        var errors = $.parseJSON(xhr.responseText).errors;
        var errores = '';
        for (i in errors) {
          errores += '*' + errors[i] + '\n';
        }
        swal({
          title: "Error",
          text: "Se produjeron los siguientes errores:\n" + errores,
          type: "error"
        });
      }
    });
  });
});

function checkFile() {
  var file_array = $('#file').val().split(".");
  if(file_array.length > 0)
  {
    var extension = file_array[file_array.length - 1];
    if (extension != "csv" && extension != "xls" && extension != "xlsx" && extension != "xlsm" && extension != "ods" && extension != "xml")
    {
      swal({
        title: "El archivo no tiene la extensión correcta",
        text: "Por favor importa sólo archivos de tipo csv o xls.",
        type: "error"
      });
      return false;
    }
    else
    {
      return true;
    }
  }
  else
  {
    swal({
      title: "No hay archivo seleccionado.",
      text: "Por favor importa sólo archivos de tipo csv o xls.",
      type: "error"
    });
    return false;
  }
}

function createDatepicker (element, options) {
  var defaults = {
    altFormat: 'dd-mm-yy',
    autoSize: false,
    firstDay: 1,
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
    monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
    prevText: 'Atrás',
    nextText: 'Adelante',
    dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
    dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    dayNamesMin: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
    today: 'Hoy',
    clear: ''
  }
  var settings = $.extend({}, defaults, options);
  $(element).datepicker(settings);
}

function findTrigger() {
  $('.search-input').keydown(function(event) {
    console.log("ENTRE: ", event)
    if (event.keyCode == 13 || event.keyCode == 10) {
      $('#search_btn').click();
      return false;
     }
  });
};

findTrigger();
