// Post
function updateCompany () {
	$('#update_company_button').addClass('disabled');
	$('#update_company_spinner').removeClass('hidden');
	var formId = $('[id^=edit_company_]').prop('id');
	$.ajax({
		type: 'POST',
		url: '/quick_add/update_company',
		data: new FormData(document.getElementById(formId)),
		mimeType: 'multipart/form-data',
		contentType: false,
		processData: false,
		success: function (result) {
			initializeStep2();
			$('#update_company_button').removeClass('disabled');
			$('#update_company_spinner').addClass('hidden');
		},
		error: function (xhr) {
			var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_company_button').removeClass('disabled');
			$('#update_company_spinner').addClass('hidden');
		},
	});
}

$(function() {
	$('#update_company_button').click(function() {
		updateCompany();
	});
});