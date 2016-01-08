$(function() {
	$('#new_client, [id^="edit_client_"]').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'client[email]': {
				email: true
			},
			'client[first_name]': {
				required: true,
				minlength: 2
			},
			'client[last_name]': {
				minlength: 2
			},
			'client[identification_number]': {
				minlength: 2
			},
			'client[phone]': {
				rangelength: [8, 15]
			},
			'client[address]': {
				minlength: 2 
			},
			'client[district]': {
				minlength: 2 
			},
			'client[city]': {
				minlength: 2 
			},
			'client[age]': {
				min: 0
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

	$('#client_upload_file_form').validate({
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

	$('#client_identification_number').change(function() {
		var id_string = $('#client_identification_number').val()
		$('#client_identification_number').val(identification_number_format(id_string));
	});
});