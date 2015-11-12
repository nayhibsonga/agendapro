$(function() {

	$('#fakePaymentIntroForm').validate({
		ignore: '.payment_date_ignore',
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
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
			console.log(element);
			$(element).closest('.payment-form-div').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			console.log(element);
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
			'payment_total_cost': {
				required: true,
				number: true
			},
			'payment_transactions_sum': {
				required: true,
				number: true,
				min: function() { return parseFloat($("#payment_total_cost").val()); }
			},
			'payment_total_change_amount': {
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
			'payment_transaction_number': {
				required: {
					depends: function () { return ($("#selected_method_number_required").val() == "1"); }
				}
			},
			'payment_transaction_installments': {
				required: {
					depends: function () { return ($('#payment_method_select option:selected').text() == "Tarjeta de Crédito"); }
				}
			},
			'payment_transaction_amount': {
				required: true,
				number: true,
				min: 1
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

	$('#addPettyTransactionForm').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'petty_transaction_amount': {
				required: true,
				min: 1
			},
			'petty_transaction_receipt_number': {
				required: {
					depends: function () { return ($('#petty_transaction_is_income').val() == "0"); }
				}
			},
			'petty_transaction_notes': {
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

	$('#fakePaymentStep3Form').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'payment_receipt_number': {
				required: {
					depends: function () { return ($('#payment_receipt_number_required').val() == "1"); }
				}
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

	$('#internalSaleForm').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'internal_sale_quantity': {
				required: true,
				number: true,
				min: 1,
				max: function() { return parseInt($("#internal_sale_product_stock").val()); }
			},
			'internal_sale_price': {
				required: true,
				number: true,
				min: 1
			},
			'internal_sale_discount': {
				required: true,
				number: true,
				min: 0
			}
		},
		highlight: function(element) {
			console.log(element);
			$(element).closest('.payment-form-div').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			console.log(element);
			$(element).closest('.payment-form-div').removeClass('has-error').addClass('has-success');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			//form.submit();
		}
	});

});