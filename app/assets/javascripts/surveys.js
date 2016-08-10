// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$('form#new_survey').submit(function(e){
  var data = $(this).serialize();
  $.ajax({
    url:$(this).attr("action"),
    type: 'POST',
    dataType: 'json',
    data: data,
    success: function(data, textStatus ){
        swal({
          title: "Enviada exitosamente.",
          type: "success"
        });
    },
    error: function(xhr, textStatus, errorThrown){
       console.log(errorThrown)
        swal({
          title: "Error al enviar, intente de nuevo.",
          type: "error"
        });
       //alert("Hubo un problema al enviar la encuesta, intente de nuevo.")
    }
  })
  return false;
})
