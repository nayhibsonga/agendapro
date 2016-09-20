function datepicker (target, config) {
  target = target || null;
  config = config || {};

  var $defaultConfig = {
    monthsFull: [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ],
    monthsShort: [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ],
    weekdaysFull: [
      'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'
    ],
    weekdaysShort: [
      'Dom', 'Lun', 'Mar', 'Mier', 'Jue', 'vie', 'Sáb'
    ],
    today: 'Hoy',
    clear: '',
    close: 'Cerrar',
    firstDay: 1,
    format: 'ddd dd/mm/yyyy',
    formatSubmit: 'yyyy/mm/dd',
    hiddenName: true
  }

  var $config = $.extend({}, $defaultConfig, config);

  if ($(target).length > 0) {
    var $datepicker = $(target).pickadate($config);
    var $picker = $datepicker.pickadate('picker');
    return $picker;
  } else {
    $.error('No target reached');
    return null;
  };
}
