// Post
function updateCompany () {
	$('#fieldset_step1').attr('disabled');
	$('#update_company_button').addClass('disabled');
	$('#update_company_spinner').show();
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
			scrollToAnchor("quick_add_step2");
			$('#fieldset_step1').removeAttr('disabled');
			$('#update_company_button').removeClass('disabled');
			$('#update_company_spinner').hide();
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
			$('#fieldset_step1').removeAttr('disabled');
			$('#update_company_button').removeClass('disabled');
			$('#update_company_spinner').hide();
		},
	});
}

$(function() {
	$('#update_company_button').click(function() {
		updateCompany();
	});
});