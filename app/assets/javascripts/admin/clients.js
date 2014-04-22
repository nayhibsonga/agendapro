
function createdComment() {
	return false;
}

function startEditComment(id) {
	var comment = $('#comment'+id).html().replace(/<br\s*[\/]?>/gi, "\n");
	$('#comment'+id).html('<textarea class="form-control" id="client_comment_comment'+id+'" rows="5">' + comment+ '</textarea>');
	$('#edit_button'+id).html('<i class="fa fa-check"></i> Guardar').removeClass('btn-warning').addClass('btn-primary');
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
	$('#edit_button'+id).html('<i class="fa fa-pencil"></i> Editar').removeClass('btn-primary').addClass('btn-warning');;
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
    if (confirm("¿Estás seguro de eliminar el Comentario seleccionado?")) {
        saveComment("DELETE",$('#client_comment_client_id').val(),{"id": id });
    }
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
				errores += errors[i];
			}
			alert(errores);
		}
	});
}

function setAge(dateText) {
	var dd = dateText.split('/');
	var date1 = new Date(dd[2]+'-'+dd[1]+'-'+dd[0]);
	var date2 = new Date();


	var milli=date2-date1;
	var milliPerYear=1000*60*60*24*365.26;

	var yearsApart=milli/milliPerYear;
	$('#client_age').val(yearsApart | 0);
	return false;
}


$(function() {
	$("#client_birth_date").datepicker({
		dateFormat: 'dd/mm/yy',
		changeMonth: true,
		changeYear: true,
		firstDay: 1,
		yearRange: "-100:+0",
		dayNames: [ "Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado" ],
		dayNamesMin: [ "Do", "Lu", "Ma", "Mi", "Ju", "Vi", "Sá" ],
		dayNamesShort: [ "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" ],
		onSelect: function(dateText, inst) {
			setAge(dateText);
		}
	});
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
	if ($('#client_birth_date').val() != '') {
		setAge($('#client_birth_date').val());
	};
});