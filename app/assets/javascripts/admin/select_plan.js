$(function() {

  /*
  * Menu & selections
  */

  $('.plan-section-link').on('click', function(){
    old_target_div = $('.plan-section-link.active').attr("targetdiv");
    $('.plan-section-link.active').removeClass('active');
    target_div = $(this).attr("targetdiv");
    $(this).addClass("active");
    $('#' + old_target_div).hide();
    $('#' + target_div).show();
  });

  $('#change_plan_pr_link').click(function(e){
    e.preventDefault();
    $('.plan-section-link[targetdiv="change_plan_div"]').trigger("click");
  });

  /*
  * Wire transfers
  */

  $('#openBillingWireTransferForm').on('click', function(){

    $('#billing_wire_transfer_amount').val($('#amount_select').val());

    $('#billingWireTransferModal').modal('show');
    $('#billing_wire_transfer_change_plan_amount').val(0);
    $('#billing_wire_transfer_new_plan_amount').val(0);
    $('#billing_wire_transfer_change_plan').val("0");
    $('#billing_wire_transfer_new_plan').val("0");

  });

  $('#openBillingWireTransferForm2').on('click', function(){

    $('#changePlanModal').modal('hide');

    $('#billing_wire_transfer_change_plan').val("1");

    $('#billingWireTransferModal').modal('show');

  });


  /*
  * Others
  */

  /*if($('#amount_select').val() != 0) {
    $('.mp_table').show();
    $('#openBillingWireTransferForm').show();
  } else {
    $('.mp_table').hide();
    $('#openBillingWireTransferForm').hide();
  }*/
  $('.mp_radio').on('change', function(){
    mp = $('.mp_radio:checked').val();
  });


  if (!$('#billing_info_active').prop('checked')) {
    $('input.form-control').attr('disabled', true);
    $('input.form-accept').attr('disabled', true);
  } else {
    $('input.form-control').attr('disabled', false);
    $('input.form-accept').attr('disabled', false);
  }
  $('#billing_info_active').change(function() {
    if (!$('#billing_info_active').prop('checked')) {
      $('input.form-control').attr('disabled', true);
      $('input.form-accept').attr('disabled', true);
    } else {
      $('input.form-control').attr('disabled', false);
      $('input.form-accept').attr('disabled', false);
    }
  });
  $('#amount_select').change(function(o) {

      $('#payBtn').attr('href', function(i,a){
        return a.replace( /\/[^\/]+$/, '/'+o.target.value );
      });
    
    /*
    $('.mp_link').each(function(i, obj) {
      $(this).attr('href', function(i,a){
        return a.replace( /\/[^\/]+$/, '/'+o.target.value );
      });
      if($('#amount_select').val() != 0) {
        $('.mp_table').show();
        $('#openBillingWireTransferForm').show();
      } else {
        $('.mp_table').hide();
        $('#openBillingWireTransferForm').hide();
      }
    });
    */

  });
  $('a.change_plan').click(function(event){
    $('#plan_mp_button').hide();
    $('#plan_mp_table').hide();
    var plan_id = event.target.id.split('change_plan_')[1];
    var months_active_left = parseFloat($('#plan_info').data('months-active-left'));
    var plan_value_left = parseFloat($('#plan_info').data('plan-value-left'));
    var due_amount = parseFloat($('#plan_info').data('due-amount'));
    var plan_price = parseFloat($('#plan_' + plan_id).data('plan-price'));
    var plan_month_value = parseFloat($('#plan_' + plan_id).data('plan-month-value'));

    $('#billing_wire_transfer_new_plan').val(plan_id);

    $('#plan_explanation').empty();
    if (months_active_left > 0) {
      if (plan_value_left > (plan_month_value + due_amount)) {
        var new_active_months_left = Math.floor((plan_value_left - plan_month_value - due_amount)/plan_price);
        var new_amount_due = -1 * (((plan_value_left - plan_month_value - due_amount)/plan_price) % 1) * plan_price;
        if (new_active_months_left > 0) {
          $('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta quedará activa por este y ' + new_active_months_left + ' mes(es) más sin pagar más y, además, quedaran abonados $ ' + Math.round((-1 * new_amount_due)) + ' en tu cuenta, para tu próximo pago.');
          $('#billing_wire_transfer_amount').val(Math.round((-1 * new_amount_due)));
          $('#billing_wire_transfer_change_plan_amount').val(Math.round((-1 * new_amount_due)));
          $('#billing_wire_transfer_new_plan_amount').val(0);
        } else {
          $('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta activa por este mes sin pagar más y, además, quedaran abonados $ ' + Math.round((-1 * new_amount_due)) + ' en tu cuenta, para tu próximo pago.');
          //$('#billing_wire_transfer_amount').val(Math.round((-1 * new_amount_due)));
        }
        $('#plan_mp_button').show();
      } else {
        $('#plan_explanation').html('Debes pagar $ ' + Math.round(plan_month_value + due_amount - plan_value_left) + ' + IVA, para cambiarte a este plan.');
        $('#plan_mp_table').show();
        $('#billing_wire_transfer_amount').val(Math.round(plan_month_value + due_amount - plan_value_left));
        //$('#billing_wire_transfer_change_plan_amount').val(Math.round((-1 * new_amount_due)));
        //$('#billing_wire_transfer_change_plan_amount').val(0);
      }
    } else {
      $('#plan_explanation').html('Debes pagar $ ' + Math.round(plan_month_value + due_amount) + ' + IVA, para cambiarte a este plan.');
      $('#plan_mp_table').show();
      $('#billing_wire_transfer_amount').val(Math.round(plan_month_value + due_amount));

    }
    $('.plan_mp_link').each(function(i, obj) {
      $(this).attr('href', function(i,a){
        return a.replace( /\/[^\/]+$/, '/' + plan_id );
      });
    });
    $('#changePlanModal').modal('show');
  });

  $('#billing-wire-transfer-form input').attr("disabled", false);

});
