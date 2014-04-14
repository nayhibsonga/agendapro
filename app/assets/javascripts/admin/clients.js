
function createdComment() {

}

function getNewClientComment() {
	var json = { "client_id": $('#client_comment_client_id').val(), "comment": $('#client_comment_comment').val() };
	return json;
}

function createComment() {
	commentJSON = getNewClientComment();
	saveComment('POST','',commentJSON);
}

function saveComment(typeURL, extraURL, json) {
	$.ajax({
		type: typeURL,
		url: '/comments'+ extraURL +'.json',
		data: { "client_comment": json },
		dataType: 'json',
		success: function(){
			document.location.href = '/clients/'+json.client_id+'/edit/';
		},
		error: function(xhr){
			var errors = $.parseJSON(xhr.responseText).errors;
			var errores = '';
			for (i in errors) {
				errores += errors[i];
			}
			alert(errores);
		}
	});
}


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
	$('#new_comment_button').click(function() {
		createComment();
		return false;
	});
	$("[id^='destroy_button']").click(function() {
		alert($(this).attr('id'));
		return false;
	});
	$("[id^='edit_button']").click(function() {
		alert($(this).attr('id'));
		return false;
	});
});