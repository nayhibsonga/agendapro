$(function() {


	$('#company_upload_file_form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'file': {
				required: true
			},
			'file_name': {
				required: true
			},
			'file_description': {
				required: true
			},
			'new_folder_name': {
				required: {
					depends: function () { return ($("#folderSelect").val() == "select"); }
				}
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			form.submit();
		}
	});


});