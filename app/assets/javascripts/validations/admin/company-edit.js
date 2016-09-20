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
				required: true
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
		var id_string = $('#company_setting_company_rut').val()
		$('#company_setting_company_rut').val(identification_number_format(id_string));
	});

});

$.validator.addMethod('promoHourCheck', function(value, element, params) {
    
    var morningStart = $("#company_setting_promo_time_attributes_morning_start_4i").val() + $("#company_setting_promo_time_attributes_morning_start_5i").val();
    var morningEnd = $("#company_setting_promo_time_attributes_morning_end_4i").val() + $("#company_setting_promo_time_attributes_morning_end_5i").val();
    var afternoonStart = $("#company_setting_promo_time_attributes_afternoon_start_4i").val() + $("#company_setting_promo_time_attributes_afternoon_start_5i").val();
    var afternoonEnd = $("#company_setting_promo_time_attributes_afternoon_end_4i").val() + $("#company_setting_promo_time_attributes_afternoon_end_5i").val();
    var nightStart = $("#company_setting_promo_time_attributes_night_start_4i").val() + $("#company_setting_promo_time_attributes_night_start_5i").val();
    var nightEnd = $("#company_setting_promo_time_attributes_night_end_4i").val() + $("#company_setting_promo_time_attributes_night_end_5i").val();

    var result = morningStart <= morningEnd;
    var result1 = afternoonStart <= afternoonEnd;
    var result2 = morningEnd <= afternoonStart;
    var result3 = nightStart <= nightEnd;
    var result4 = afternoonEnd <= nightStart;


    $("#morning-error").empty();
    $("#morning-error").hide();
    $("#afternoon-error").empty();
    $("#afternoon-error").hide();
    $("#night-error").empty();
    $("#night-error").hide();

    if (result)
    {
    	$(".morning-promo-hour").addClass('has-success').removeClass('has-error');
    	$(".morning-promo-hour").children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
    }
    else
    {
    	$(".morning-promo-hour").removeClass('has-success').addClass('has-error');
    	$(".morning-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
    	$("#morning-error").append("El fin de la mañana no puede ser menor al inicio.");
    	$("#morning-error").show();
    }


    if (result1 && result2)
    {
    	$(".afternoon-promo-hour").addClass('has-success').removeClass('has-error');
    	$(".afternoon-promo-hour").children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
    }
    else
    {

    	$(".afternoon-promo-hour").removeClass('has-success').addClass('has-error');
    	$(".afternoon-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
    	var strError = "";
    	if(!result1 && result2)
    	{
    		strError = "El fin de la tarde no puede ser menor al inicio.";
    	}
    	else if(!result2 && result1)
    	{
    		strError = "El inicio de la tarde no puede ser menor al fin de la mañana.";
    		$(".morning-promo-hour").removeClass('has-success').addClass('has-error');
	    	$(".morning-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
	    	$("#morning-error").append("El fin de la mañana no puede ser mayor al inicio de la tarde.");
	    	$("#morning-error").show();
    	}
    	else
    	{
    		strError = "El inicio de la tarde no puede ser menor al fin de la mañana ni mayor al fin de la tarde.";
    		$(".morning-promo-hour").removeClass('has-success').addClass('has-error');
	    	$(".morning-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
	    	$("#morning-error").append("El fin de la mañana no puede ser mayor al inicio de la tarde.");
	    	$("#morning-error").show();
    	}
    	$("#afternoon-error").append(strError);
    	$("#afternoon-error").show();
    }


    

    if (result3 && result4)
    {
    	$(".night-promo-hour").addClass('has-success').removeClass('has-error');
    	$(".night-promo-hour").children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
    }
    else
    {

    	$(".night-promo-hour").removeClass('has-success').addClass('has-error');
    	$(".night-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
    	var strError = "";
    	if(!result3 && result4)
    	{
    		strError = "El fin de la noche no puede ser menor al inicio.";
    	}
    	else if(!result4 && result3)
    	{
    		strError = "El inicio de la noche no puede ser menor al fin de la tarde.";
    		$(".afternoon-promo-hour").removeClass('has-success').addClass('has-error');
	    	$(".afternoon-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
	    	$("#afternoon-error").append("El fin de la tarde no puede ser mayor al inicio de la noche.");
	    	$("#afternoon-error").show();
    	}
    	else
    	{
    		strError = "El inicio de la noche no puede ser menor al fin de la tarde ni mayor al fin de la noche.";
    		$(".afternoon-promo-hour").removeClass('has-success').addClass('has-error');
	    	$(".afternoon-promo-hour").children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
	    	$("#afternoon-error").append("El fin de la tarde no puede ser mayor al inicio de la noche.");
	    	$("#afternoon-error").show();
    	}
    	$("#night-error").append(strError);
    	$("#night-error").show();
    }

    return result && result1 && result2 && result3 && result4;

}, 'Algunos horarios no son correctos.');


$(function() {
	$('#promo-times-form').validate({
		errorPlacement: function(error, element) {
			/*error.appendTo(element.parent().next());
			console.log(element.parent().next());*/
		},
		rules: {
			'company_setting[promo_time_attributes][morning_start(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][morning_start(5i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][morning_end(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][morning_end(5i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][afternoon_start(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][afternoon_start(5i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][afternoon_end(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][afternoon_end(5i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][night_start(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][night_start(5i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][night_end(4i)]': {
				required: true,
				promoHourCheck: true
			},
			'company_setting[promo_time_attributes][night_end(5i)]': {
				required: true,
				promoHourCheck: true
			}
		},
		highlight: function(element) {
			//console.log($(element));
			/*$(element).parent().removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');*/
		},
		success: function(element) {
			//console.log($(element).parent());
			/*$(element).closest('promo-hour-select').removeClass('has-error').addClass('has-success');
			$(element).parent().removeClass('has-error').addClass('has-success');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');*/
			//$(element).parent().empty()
		},
		submitHandler: function(form) {
			form.submit();
		}
	});

});
