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
			d = new Date();
			if (result != null && result != "null") {
				$('#company_logo_img').attr("src", result+"?ts="+d.getTime());
			}
			initializeStep2();
			$('#fieldset_step2').show();
			$('#fieldset_step2').attr('disabled', false);
			scrollToAnchor("fieldset_step2");
			$('#fieldset_step1').show();
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
		if ($('[id^="edit_company_"]').valid()) {
			updateCompany();
		};
	});
	$("input:file").change(function (){
		if ($('[id^="edit_company_"]').valid()) {
	    var formId = $('[id^=edit_company_]').prop('id');
			$.ajax({
				type: 'POST',
				url: '/quick_add/update_company',
				data: new FormData(document.getElementById(formId)),
				mimeType: 'multipart/form-data',
				contentType: false,
				processData: false,
				success: function (result) {
					window.console.log(result);
					d = new Date();
					$('#company_logo_img').attr("src", result+"?ts="+d.getTime());
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
				},
			});
		};
  });
});
