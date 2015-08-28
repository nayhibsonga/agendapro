$(function () {
	$("#from").datepicker({
    dateFormat: 'dd-mm-yy',
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
    	nextDate = $("#from").datepicker("getDate");
    	nextDate.setFullYear(nextDate.getFullYear() + 1);
	    $('#to').datepicker("option", {
	    	minDate: newDate,
	    	maxDate: nextDate
	    });
    }
  });
  $("#to").datepicker({
    dateFormat: 'dd-mm-yy',
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
	// $('#location').change( function () {
	// 	var localId = $('#location').val();
	// 	if ($('#location').val() > 0) {
	// 		$.getJSON('/local_providers', {location: localId }, function (providersArray) {
	// 			$('#provider').empty();
	// 			$('#provider').append('<option value="">Elige un Prestador...</option>');
	// 			$.each(providersArray, function (key, provider) {
	// 				$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
	// 			});
	// 		});
	// 	}
	// 	else {
	// 		$.getJSON('/service_providers.json', function (providersArray) {
	// 			$('#provider').empty();
	// 			$('#provider').append('<option value="">Elige un Prestador...</option>');
	// 			$.each(providersArray, function (key, provider) {
	// 				$('#provider').append('<option value="' + provider.id + '">' + provider.public_name + '</option>');
	// 			});
	// 		});
	// 	}
	// });
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
