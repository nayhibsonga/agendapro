$(function() {
	$('#company-form').validate({
		errorPlacement: function(error, element) {
			if (element.attr('id') == 'company_web_address') {
				error.appendTo(element.parent().next());
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'company[name]': {
				required: true,
				minlength: 3,
				maxlength: 200
			},
			'company[web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				alphaNumeric: $('#company_web_address').val()
			},
			'company[logo]': {
				filesize: 3145728
			}
		},
		messages: {
			'company[logo]': {
				filesize: "La imagen supera el tamaño maximo de 3 MB"
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

$(function() {
	$('#online-payment-form').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			if (id == 'company_setting_online_cancelation_policy_attributes_min_hours' || id == 'company_setting_online_cancelation_policy_attributes_cancel_max') {
				error.appendTo(element.parent().next());
			}
			else if (id == 'company_setting_online_cancelation_policy_attributes_modification_max') {
				error.appendTo(element.next().next());
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'company_setting[account_name]': {
				required: true
			},
			'company_setting[company_rut]': {
				required: true,
				rut: true
			},
			'company_setting[account_number]': {
				required: true
			},
			'company_setting[online_cancelation_policy_attributes][cancel_max]': {
				required: true,
				max: 48
			},
			'company_setting[online_cancelation_policy_attributes][min_hours]': {
				required: true
			},
			'company_setting[online_cancelation_policy_attributes][modification_max]': {
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
			form.submit();
		}
	});

	$('#company_setting_company_rut').change(function() {
		var rut_string = $('#company_setting_company_rut').val()
		$('#company_setting_company_rut').val(rut_format(rut_string));
	});

});

$.validator.addMethod('morning', function(value, element, params) {
    
    var morningStart = $("#company_setting_promo_time_attributes_morning_start_4i").val() + $("#company_setting_promo_time_attributes_morning_start_5i").val();
    var morningEnd = $("#company_setting_promo_time_attributes_morning_end_4i").val() + $("#company_setting_promo_time_attributes_morning_end_5i").val();

    return morningStart <= morningEnd;

}, 'El fin de la mañana no puede ser menor al inicio.');

$.validator.addMethod('afternoon', function(value, element, params) {
    
    var afternoonStart = $("#company_setting_promo_time_attributes_afternoon_start_4i").val() + $("#company_setting_promo_time_attributes_afternoon_start_5i").val();
    var afternoonEnd = $("#company_setting_promo_time_attributes_afternoon_end_4i").val() + $("#company_setting_promo_time_attributes_afternoon_end_5i").val();
    var morningEnd = $("#company_setting_promo_time_attributes_morning_end_4i").val() + $("#company_setting_promo_time_attributes_morning_end_5i").val();

    return afternoonStart <= afternoonEnd && morningEnd <= afternoonStart;

}, 'El inicio de la tarde no puede ser menor al fin de la mañana ni mayor al fin de la tarde.');

$.validator.addMethod('night', function(value, element, params) {
    
    var nightStart = $("#company_setting_promo_time_attributes_night_start_4i").val() + $("#company_setting_promo_time_attributes_night_start_5i").val();
    var afternoonEnd = $("#company_setting_promo_time_attributes_afternoon_end_4i").val() + $("#company_setting_promo_time_attributes_afternoon_end_5i").val();
    var nightEnd = $("#company_setting_promo_time_attributes_night_end_4i").val() + $("#company_setting_promo_time_attributes_night_end_5i").val();

    return nightStart <= nightEnd && afternoonEnd <= nightStart;

}, 'El inicio de la tarde no puede ser menor al fin de la mañana ni mayor al fin de la tarde.');


$(function() {
	$('#promo-times-form').validate({
		errorPlacement: function(error, element) {
			var id = element.attr('id');
			error.appendTo(element.parent().next());
		},
		rules: {
			'company_setting[promo_time_attributes][morning_start(4i)]': {
				required: true,
				morning: true
			},
			'company_setting[promo_time_attributes][morning_start(5i)]': {
				required: true,
				morning: true
			},
			'company_setting[promo_time_attributes][morning_end(4i)]': {
				required: true,
				morning: true
			},
			'company_setting[promo_time_attributes][morning_end(5i)]': {
				required: true,
				morning: true
			},
			'company_setting[promo_time_attributes][afternoon_start(4i)]': {
				required: true,
				afternoon: true
			},
			'company_setting[promo_time_attributes][afternoon_start(5i)]': {
				required: true,
				afternoon: true
			},
			'company_setting[promo_time_attributes][afternoon_end(4i)]': {
				required: true,
				afternoon: true
			},
			'company_setting[promo_time_attributes][afternoon_end(5i)]': {
				required: true,
				afternoon: true
			},
			'company_setting[promo_time_attributes][night_start(4i)]': {
				required: true,
				night: true
			},
			'company_setting[promo_time_attributes][night_start(5i)]': {
				required: true,
				night: true
			},
			'company_setting[promo_time_attributes][night_end(4i)]': {
				required: true,
				night: true
			},
			'company_setting[promo_time_attributes][night_end(5i)]': {
				required: true,
				night: true
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
