$(function() {
	$('#bookingForm').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'user[full_name]': {
				required: true
			},
			phone: {
				rangelength: [8, 15]
			},
			email: {
				required: true,
				email: true
			},
			identification_number: {
				rut:true,
				minlength: 2
			},
			address: {
				minlength: 3
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
	$('#identification_number').change(function() {
		var rut_string = $('#identification_number').val()
		$('#identification_number').val(rut_format(rut_string));
		$.getJSON('/client_loader', {term: $('#identification_number').val()}, function (client) {
			if (client != null){	
				$('#full_name').val(client.first_name+' '+client.last_name);
				$('#firstName').val(client.first_name);
				$('#lastName').val(client.last_name);
			}
			else {
				$('#full_name').val('');
				$('#firstName').val('');
				$('#lastName').val('');
			}
		});
	});
});