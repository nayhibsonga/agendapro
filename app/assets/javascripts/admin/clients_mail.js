$(function () {
  $("#from_display").datepicker({
    dateFormat: 'dd M',
    altField: '#from',
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
    clear: '',
    onSelect: function(newDate){
      nextDate = $("#from_display").datepicker("getDate");
      nextDate.setFullYear(nextDate.getFullYear() + 1);
      $('#to_display').datepicker("option", {
        minDate: newDate,
        maxDate: nextDate
      });
    }
  });
  $("#to_display").datepicker({
    dateFormat: 'dd M',
    altField: '#to',
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
  });

  $('#addFilter + .dropdown-menu > li > a').click(function (event) {
    event.preventDefault();
    menu = $(event.target);
    menu.parent().addClass('hidden');
    target = menu.data('target');
    animateIn($(target));
  });

  $('.filter-body a').click(function (event) {
    event.preventDefault();
    cross = $(event.target).closest('a');
    animateOut(cross.parents('.form-group'));
    menu = $(cross.data('target'));
    menu.parent().removeClass('hidden');
    removeData(cross.parents('.form-group'));
  });

  $('#file').change( function () {
    if ($('#file').val()) {
      $('#import_button').removeAttr("disabled");
    }
    else {
      $('#import_button').attr("disabled", "disabled");
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
        var errores = 'Error\n';
        for (i in errors) {
          errores += '*' + errors[i] + '\n';
        }
        alert(errores);
      }
    });
  });
});

function animateIn (element) {
  element.removeClass('hidden');
  height = element.outerHeight();
  element.detach();
  element.css({height: 0});
  $('.filter-body').prepend(element);
  element.animate({height: height}, 500, function () {
    element.css("height", "auto");
  });
}

function animateOut (element) {
  height = element.outerHeight();
  element.animate({height: 0}, 500, function () {
    element.addClass('hidden');
    element.css({height: height});
  });
}

function removeData(element) {
  children = element.find('input[type="checkbox"]');
  $.each(children, function (i, child) {
    $(child).prop('checked', false);
  });
  children = element.find('input[type="text"]');
  $.each(children, function (i, child) {
    $(child).val('');
  });
}
