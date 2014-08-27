$(function() {
	if($('#amount_select').val() != 0) {
		$('#mp_table').show();
	}
	else {
		$('#mp_table').hide();
	}
	if (!$('#billing_info_active').prop('checked')) {
		$('input.form-control').attr('disabled', true);
		$('input.form-accept').attr('disabled', true);
	}
	else {
		$('input.form-control').attr('disabled', false);
		$('input.form-accept').attr('disabled', false);
	}
	$('#billing_info_active').change(function() {
		if (!$('#billing_info_active').prop('checked')) {
			$('input.form-control').attr('disabled', true);
			$('input.form-accept').attr('disabled', true);
		}
		else {
			$('input.form-control').attr('disabled', false);
			$('input.form-accept').attr('disabled', false);
		}
	});
	$('#amount_select').change(function(o) {
		$('.mp_link').each(function(i, obj) { 
			$(this).attr('href', function(i,a){
				return a.replace( /\/[^\/]+$/, '/'+o.target.value );
			});
			if($('#amount_select').val() != 0) {
				$('#mp_table').show();
			}
			else {
				$('#mp_table').hide();
			}
		});
	});
	$('a.change_plan').click(function(event){
		$('#plan_mp_button').hide();
		$('#plan_mp_table').hide();
		var plan_id = event.target.id.split('change_plan_')[1];
		var months_active_left = parseFloat($('#plan_info').data('months-active-left'));
		var plan_value_left = parseFloat($('#plan_info').data('plan-value-left'));
		var due_amount = parseFloat($('#plan_info').data('due-amount'));
		var plan_price = parseFloat($('#plan_'+plan_id).data('plan-price'));
		var plan_month_value = parseFloat($('#plan_'+plan_id).data('plan-month-value'));
		$('#plan_explanation').empty();
		if (months_active_left > 0) {
			if (plan_value_left > (plan_month_value + due_amount)) {
				var new_active_months_left = Math.floor((plan_value_left - plan_month_value - due_amount)/plan_price);
				var new_amount_due = -1*(((plan_value_left - plan_month_value - due_amount)/plan_price)%1)*plan_price;
				if (new_active_months_left > 0) {
					$('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta quedará activa por este y '+new_active_months_left+' mes(es) más sin pagar más y, además, quedaran abonados $ '+Math.round((-1*new_amount_due))+' CLP en tu cuenta, para tu próximo pago.');
				}
				else {
					$('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta activa por este mes sin pagar más y, además, quedaran abonados $ '+Math.round((-1*new_amount_due))+' CLP en tu cuenta, para tu próximo pago.');
				}
				$('#plan_mp_button').show();
			}
			else {
				$('#plan_explanation').html('Debes pagar $ '+Math.round(plan_month_value + due_amount - plan_value_left)+' CLP + IVA, para cambiarte a este plan.');
				$('#plan_mp_table').show();
			}
		}
		else {
			$('#plan_explanation').html('Debes pagar $ '+Math.round(plan_month_value + due_amount)+' CLP + IVA, para cambiarte a este plan.');
			$('#plan_mp_table').show();
		}
		$('.plan_mp_link').each(function(i, obj) { 
			$(this).attr('href', function(i,a){
				return a.replace( /\/[^\/]+$/, '/'+plan_id );
			});
		});
		$('#changePlanModal').modal('show');
	});
});