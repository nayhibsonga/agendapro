$(function() {
	$("#client_birth_date").datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true,
		firstDay: 1,
		dayNames: [ "Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado" ],
		dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sá" ],
		dayNamesShort: [ "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" ]
	});
});