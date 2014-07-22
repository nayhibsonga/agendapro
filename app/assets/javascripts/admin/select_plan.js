$(function() {
	if($('#amount_select').val() != 0) {
		$('#mp_table').show();
	}
	else {
		$('#mp_table').hide();
	}
	if (!$('#billing_info_active').prop('checked')) {
		$('input.form-control').attr('disabled', true);
	}
	else {
		$('input.form-control').attr('disabled', false);
	}
	$('#billing_info_active').change(function() {
		if (!$('#billing_info_active').prop('checked')) {
			$('input.form-control').attr('disabled', true);
		}
		else {
			$('input.form-control').attr('disabled', false);
		}
	});
	$('#amount_select').change(function(o) {
		$('.mp_link').each(function(i, obj) { 
			$(this).attr('href', function(i,a){
				return a.replace( /(amount=)[0-9]+/ig, '$1'+o.target.value );
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
		var plan_id = event.target.id.split('change_plan_')[1];
		window.console.log($('#plan_difference_'+plan_id).data('months-active-left'));
		window.console.log($('#plan_difference_'+plan_id).data('due-difference'));
		window.console.log($('#plan_difference_'+plan_id).data('plan-difference'));
		$('#plan_explanation').empty();

		$('#changePlanModal').modal('show');
	});
	// <td>
 //          <% @plan_difference = (@company.due_amount + (@month_days - @day_number)*(plan.price - @price)/@month_days)*(1+@sales_tax) %>
 //          <% if @company.months_active_left > 0 %>
 //            <% if @plan_difference > 0 %>
 //              Debes pagar <%= number_to_currency((@plan_difference + (plan.price - @price)*(@company.months_active_left - 1)), {:unit => '$', :separator => ',', :delimiter => '.', :precision => 0}) %> CLP, para cambiarte a este plan.
 //            <% else %>
 //              Se te abonarán <%= number_to_currency(-1*(@plan_difference + (plan.price - @price)*(@company.months_active_left - 1)), {:unit => '$', :separator => ',', :delimiter => '.', :precision => 0}) %> CLP para tu cuenta AgendaPro, si te cambias a este plan.
 //            <% end %>
 //          <% else %>
 //            Diferencia de <%= number_to_currency(@plan_difference, {:unit => '$', :separator => ',', :delimiter => '.', :precision => 0}) %> CLP, al pagar tu plan para este mes.
 //          <% end %>
            
 //        </td>
});