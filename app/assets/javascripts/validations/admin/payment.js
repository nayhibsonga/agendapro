$(function() {

	$('#fakePaymentIntroForm').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'payment_client_name': {
				required: {
					depends: function () { return ($("#set_client").val() == "1"); }
				}
			},
			'payment_client_email': {
				required: {
					depends: function () { return ($("#set_client").val() == "1"); }
				}
			},
			'payment_client_phone': {
				required: {
					depends: function () { return ($("#set_client").val() == "1"); }
				}
			},
			'payment_client_gender': {
				required: {
					depends: function () { return ($("#set_client").val() == "1"); }
				}
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
			//form.submit();
		}
	});

	$('#fakePaymentStep2Form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'payment_cost': {
				required: true,
				number: true
			},
			'payment_paid_amount': {
				required: true,
				number: true
			},
			'payment_change_amount': {
				required: true,
				number: true
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
			//form.submit();
		}
	});

	$('#fakeMethodDetailsForm').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'payment_check_number': {
				required: {
					depends: function () { return ($("#selected_pay_method").val() == "check"); }
				}
			},
			'payment_credit_card_number': {
				required: {
					depends: function () { return ($("#selected_pay_method").val() == "credit_card"); }
				}
			},
			'payment_credit_card_dues_number': {
				required: {
					depends: function () { return ($("#selected_pay_method").val() == "credit_card"); }
				},
				number: true
			},
			'payment_debt_card_number': {
				required: {
					depends: function () { return ($("#selected_pay_method").val() == "debt_card"); }
				}
			},
			'payment_other_method_number': {
				required: {
					depends: function () { return ($("#selected_pay_method").val() == "other" && $('.payment_other_method_type_number_required[method_id="' + $("#payment_other_method_type").val() + '"]').val() == "true"); }
				}
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
			//form.submit();
		}
	});

	$('#fakePaymentStep3Form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'payment_receipt_number': {
				required: true
			},
			'payment_receipt_date': {
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
			//form.submit();
		}
	});

});