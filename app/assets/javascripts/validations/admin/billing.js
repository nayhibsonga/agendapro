$(function() {


	$('#save_billing_wire_transfer_form').validate({
		ignore: '.payment_date_ignore',
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'transfer_receipt_number': {
				required: true
			},
			'transfer_account_name': {
				required: true
			},
			'transfer_account_number': {
				required: true
			}
		},
		highlight: function(element) {
			$(element).closest('.payment-form-div').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			$(element).closest('.payment-form-div').removeClass('has-error').addClass('has-success');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			var date = $('#transfer_payment_date').val();
      		var time = $('#transfer_payment_time_4i').val() + ":" + $('#transfer_payment_time_5i').val() + ":00";
      		$('#transfer_datetime').val(date + " " + time);
			form.submit();
		}
	});


	$('input[name="billing_info[accept]"]:hidden').attr('name', 'temp_checkbox');
	$('#new_billing_info, [id^="edit_billing_info_"]').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (element.attr('id') == 'billing_info_accept') {
				error.appendTo(element.parent().next());
			}
			else{
				error.appendTo(element.next());
			};
		},
		rules: {
			'billing_info[rut]': {
				required: true
			},
			'billing_info[name]': {
				required: true
			},
			'billing_info[sector]': {
				required: true
			},
			'billing_info[contact]': {
				required: true
			},
			'billing_info[address]': {
				required: true
			},
			'billing_info[phone]': {
				required: true
			},
			'billing_info[email]': {
				required: true,
				email: true
			},
			'billing_info[accept]': {
				required: true
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
			$('input[name="temp_checkbox"]:hidden').attr('name', 'billing_info[accept]');
			form.submit();
		}
	});
	$('#billing_info_rut').change(function() {
		var id_string = $('#billing_info_rut').val()
		$('#billing_info_rut').val(identification_number_format(id_string));
	});
});
