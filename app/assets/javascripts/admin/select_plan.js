$(function() {

  var datetime_str = new Date().toTimeString();
  console.log(datetime_str);
  var time_str = datetime_str.split(" ")[0].split(":");
  var time_hour = time_str[0];
  var time_minute = time_str[1];

  console.log(time_hour);
  console.log(time_minute);

  $("#transfer_payment_time_4i").val(time_hour);
  $("#transfer_payment_time_5i").val(time_minute);

  $("#transfer_payment_date").datepicker({
    dateFormat: 'dd/mm/yy',
    autoSize: true,
    firstDay: 1,
    changeMonth: true,
    changeYear: true,
    monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
        monthNamesShort: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'],
        prevText: 'Atrás',
        nextText: 'Adelante',
        dayNames: ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'],
        dayNamesShort: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
        dayNamesMin: ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'],
        today: 'Hoy',
        clear: ''
  });

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

  $('#openPayDiv').on('click', function(){
    old_target_div = $('.plan-section-link.active').attr("targetdiv");
    $('.plan-section-link.active').removeClass('active');
    target_div = "pay_div";
    $('.plan-section-link[targetdiv="pay_div"]').addClass("active");
    $('#' + old_target_div).hide();
    $('#pay_div').show();
  });

  $('#change_plan_pr_link').click(function(e){
    e.preventDefault();
    $('.plan-section-link[targetdiv="change_plan_div"]').trigger("click");
  });

  /*
  * Wire transfers
  */

  /*$('#openBillingWireTransferForm').on('click', function(){

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

  });*/

  $('#wireTransferBtn').on('click', function(){
    if($('#amount_select').val() == "0" || $('.mp_radio:checked').length < 1)
    {
      swal({
        title: "Elige una opción de pago primero.",
        type: "error"
      });
      return false;
    }
    $('#transferModal').modal('show');
    $('#transfer_amount').val($('#amount_select option:selected').attr("amount"));
    $('#transfer_amount_detail').html($('#amount_select option:selected').text());
    $('#transfer_change_plan').val("0");
    $('#transfer_new_plan').val("0");
    $('#transfer_paid_months').val($('#amount_select').val());
    $('#saveTransferBtn').attr('disabled', false);
  });

  $('#changePlanWireTransferBtn').on('click', function(){
    $('#changePlanModal').modal('hide');
    $('#transferModal').modal('show');
    $('#transfer_change_plan').val("1");
    $('#transfer_new_plan').val($('#new_plan_id').val())
    $('#transfer_paid_months').val("0");
    $('#saveTransferBtn').attr('disabled', false);
  });

  $('#reactivateWireTransferBtn').on('click', function(){
    $('#transferModal').modal('show');
    $('#transfer_change_plan').val("1");
    $('#transfer_amount').val($('#renovation_amount').val());
    $('#transfer_amount_detail').html($('#renovation_amount_detail').val());
    $('#transfer_new_plan').val($('#new_plan_id').val())
    $('#transfer_paid_months').val("0");
    $('#saveTransferBtn').attr('disabled', false);
  });


  /*$('#saveTransferBtn').on('click', function(){

    if($('#save_billing_wire_transfer_form').valid())
    {
      var date = $('#transfer_payment_date').val();
      var time = $('#transfer_payment_time_4i').val() + ":" + $('#transfer_payment_time_5i').val() + ":00";
      $('#transfer_datetime').val(date + " " + time);

      $('#save_billing_wire_transfer_form').submit();

    }

  });*/

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
    var new_params = "/" + mp + "/" + $("#amount_select").val();
    var cut_str = "generate_company_transaction";
    var curr_href = $('#payBtn').attr('href');
    var cut_index = curr_href.indexOf(cut_str);
    cut_index += cut_str.length;

    curr_href = curr_href.substring(0, cut_index) + new_params;

    if(mp != "000")
    {
      $('#payBtn').attr('href', curr_href);
      $('#payBtn').show();
      $('#payBtn').attr('disabled', false);
      $('#payBtn').find('button').attr('disabled', false);
      $('#wireTransferBtn').hide();
      $('#payWireTransferSelected').hide();
    }
    else
    {
      $('#payWireTransferSelected').show();
      $('#wireAmount').html($('#amount_select option:selected').text());
      $('#payBtn').hide();
      $('#wireTransferBtn').show();
      $('#wireTransferBtn').attr('disabled', false);
    }

  });

  $('.change_plan_mp_radio').on('change', function(){

    mp = $('.change_plan_mp_radio:checked').val();
    var new_params = "/" + mp + "/" + $('#new_plan_id').val();
    var cut_str = "generate_plan_transaction";
    var curr_href = $('#changePlanPayBtn').attr('href');
    var cut_index = curr_href.indexOf(cut_str);
    cut_index += cut_str.length;

    curr_href = curr_href.substring(0, cut_index) + new_params;

    if(mp != "000")
    {
      $('#changePlanPayBtn').attr('href', curr_href);
      $('#changePlanPayBtn').show();
      $('#changePlanPayBtn').attr('disabled', false);
      $('#changePlanPayBtn').find('button').attr('disabled', false);
      $('#changePlanWireTransferBtn').hide();
      $('#changeWireTransferSelected').hide();
    }
    else
    {
      $('#changeWireTransferSelected').show();
      $('#changePlanPayBtn').hide();
      $('#changePlanWireTransferBtn').show();
      $('#changePlanWireTransferBtn').attr('disabled', false);
    }

  });

  $('.reactivate_mp_radio').on('change', function(){

    mp = $('.reactivate_mp_radio:checked').val();
    var new_params = "/" + mp;
    var cut_str = "generate_reactivation_transaction";
    var curr_href = $('#reactivatePayBtn').attr('href');
    var cut_index = curr_href.indexOf(cut_str);
    cut_index += cut_str.length;

    curr_href = curr_href.substring(0, cut_index) + new_params;

    if(mp != "000")
    {
      $('#reactivatePayBtn').attr('href', curr_href);
      $('#reactivatePayBtn').show();
      $('#reactivatePayBtn').attr('disabled', false);
      $('#reactivatePayBtn').find('button').attr('disabled', false);
      $('#reactivateWireTransferBtn').hide();
      $('#renovateWireTransferSelected').hide();
    }
    else
    {
      $('#renovateWireTransferSelected').show();
      $('#reactivatePayBtn').hide();
      $('#reactivateWireTransferBtn').show();
      $('#reactivateWireTransferBtn').attr('disabled', false);
    }

  });


  if (!$('#billing_info_active').prop('checked')) {
    $('#new_billing_info input.form-control').attr('disabled', true);
    $('#new_billing_info input.form-accept').attr('disabled', true);
  } else {
    $('#new_billing_info input.form-control').attr('disabled', false);
    $('#new_billing_info input.form-accept').attr('disabled', false);
  }
  $('#billing_info_active').change(function() {
    if (!$('#billing_info_active').prop('checked')) {
      $('#new_billing_info input.form-control').attr('disabled', true);
      $('#new_billing_info input.form-accept').attr('disabcdled', true);
    } else {
      $('#new_billing_info input.form-control').attr('disabled', false);
      $('#new_billing_info input.form-accept').attr('disabled', false);
    }
  });

  $('#amount_select').change(function(o) {

    if($(this).val() != "0")
    {
      $('#pay_div_payment_method').show();
    }
    else
    {
      $('#pay_div_payment_method').hide();
    }

    if($('#payBtn').length > 0)
    {
      mp = $('.mp_radio:checked').val();
      var new_params = "/" + mp + "/" + $("#amount_select").val();
      var cut_str = "generate_company_transaction";
      var curr_href = $('#payBtn').attr('href');
      var cut_index = curr_href.indexOf(cut_str);
      cut_index += cut_str.length;

      $('#wireAmount').html($('#amount_select option:selected').text());

      curr_href = curr_href.substring(0, cut_index) + new_params;

      if(mp != "000")
      {
        $('#payBtn').attr('href', curr_href);
        $('#payBtn').show();
        $('#payBtn').attr('disabled', false);
        $('#payBtn').find('button').attr('disabled', false);
        $('#wireTransferBtn').hide();
      }
      else
      {
        $('#payBtn').hide();
        $('#wireTransferBtn').show();
        $('#wireTransferBtn').attr('disabled', false);
      }
    }
    else
    {
      var new_params = "/" + $("#amount_select").val();
      var cut_str = "generate_company_transaction";
      var curr_href = $('#payBtnCol').attr('href');
      var cut_index = curr_href.indexOf(cut_str);
      cut_index += cut_str.length;
      curr_href = curr_href.substring(0, cut_index) + new_params;
      console.log("Acá");
      console.log(curr_href);
      $('#payBtnCol').attr('href', curr_href);
      $('#payBtnCol').show();
      //$('#payBtnCol').attr('disabled', false);
      //$('#payBtnCol').find('button').attr('disabled', false);
    }

  });

  $('.change-plan').on('click', function(){

    $('#plan_mp_button').hide();
    $('#plan_mp_table').hide();
    $('#change_plan_free').hide();
    var plan_id = $(this).attr("plan_id");
    var current_plan_price = parseFloat($('#plan_info').data('plan_price'));
    var months_active_left = parseFloat($('#plan_info').data('months-active-left'));
    var plan_value_left = parseFloat($('#plan_info').data('plan-value-left'));
    var plan_value_taken = parseFloat($('#plan_info').data('plan-value-taken'));
    var due_amount = parseFloat($('#plan_info').data('due-amount'));
    var plan_price = parseFloat($('#plan_' + plan_id).data('plan-price'));
    var plan_month_value = parseFloat($('#plan_' + plan_id).data('plan-month-value'));
    var sales_tax = parseFloat($('#sales_tax').val());
    console.log(sales_tax);
    console.log("plan_value_left " + plan_value_left);
    console.log("plan_month_value " + plan_month_value);
    console.log("plan_price " + plan_price);


    $('#transfer_new_plan').val(plan_id);

    $('#plan_explanation').empty();
    if (months_active_left > 0) {
      if (plan_value_left > (plan_month_value + due_amount)) {

        console.log("Calc 1: " + Math.round((plan_value_left * (1 + sales_tax) - plan_month_value * (1 + sales_tax) - due_amount)));
        console.log("Calc 2: " + Math.round((plan_price * (1 + sales_tax))));

        var calc_months = (plan_value_left * (1 + sales_tax) - plan_month_value * (1 + sales_tax) - due_amount)/(plan_price * (1 + sales_tax));
        console.log("Calc months: " + calc_months);

        var new_active_months_left = Math.floor(Math.round(plan_value_left * (1 + sales_tax) - plan_month_value * (1 + sales_tax) - due_amount)/Math.round(plan_price * (1 + sales_tax)));
        var new_amount_due = -1 * ((Math.round(plan_value_left * (1 + sales_tax) - plan_month_value* (1 + sales_tax) - due_amount)/Math.round(plan_price * (1 + sales_tax))) % 1) * plan_price * (1 + sales_tax);
        console.log("New amount due: " + new_amount_due);
        if (new_active_months_left > 0) {
          $('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta quedará activa por este y ' + new_active_months_left + ' mes(es) más sin pagar más y, además, quedaran abonados $ ' + Math.round((-1 * new_amount_due)) + ' en tu cuenta, para tu próximo pago.');
          $('#billing_wire_transfer_amount').val(Math.round((-1 * new_amount_due)));
          $('#billing_wire_transfer_change_plan_amount').val(Math.round((-1 * new_amount_due)));
          $('#billing_wire_transfer_new_plan_amount').val(0);
          $('#wireChangeAmount').text('$ ' + $('#billing_wire_transfer_amount').val());
        } else {
          $('#plan_explanation').html('Si te cambias a este nuevo Plan, tu cuenta queda activa por este mes sin pagar más y, además, quedaran abonados $ ' + Math.round((-1 * new_amount_due)) + ' en tu cuenta, para tu próximo pago.');
          //$('#billing_wire_transfer_amount').val(Math.round((-1 * new_amount_due)));
        }
        $('#plan_mp_button').show();
        $('#change_plan_free').show();
        $('#changePlanBtn').attr('href', function(i,a){
          return a.replace( /\/[^\/]+$/, '/' + plan_id );
        });
      } else {
        $('#plan_explanation').html('Debes pagar $ ' + Math.round(plan_month_value + due_amount / (1 + sales_tax) - plan_value_left) + ' + IVA ($' + Math.round( (plan_month_value + due_amount / (1 + sales_tax) - plan_value_left) * (1 + sales_tax)) + '), para cambiarte a este plan.');
        $('#plan_mp_table').show();
        $('#transfer_amount').val(Math.round( (plan_month_value * (1 + sales_tax) + due_amount - plan_value_left * (1 + sales_tax))));
        $('#transfer_amount_detail').text('$ ' + $('#transfer_amount').val());
        $('#wireChangeAmount').text('$ ' + $('#transfer_amount').val());
        //$('#billing_wire_transfer_change_plan_amount').val(Math.round((-1 * new_amount_due)));
        //$('#billing_wire_transfer_change_plan_amount').val(0);
      }
    } else {

      /*
      Should pay days of the month passed with current_price, and forward days with new_price, plus debt
      But only when "Emitido"
      If "Bloqueado or Inactivo", should only add forward days.
      */



      var computed_price = plan_value_taken + due_amount / (1 + sales_tax) + plan_month_value;
      if($('#blocked_or_inactive').val() == "1")
      {
        computed_price = due_amount / (1 + sales_tax) + plan_month_value;
      }
      console.log("plan_value_taken " + plan_value_taken);
      console.log("due_amount " + due_amount);
      console.log("plan_month_value " + plan_month_value);

      $('#plan_explanation').html('Debes pagar $ ' + Math.round( computed_price ) + ' + IVA ($' + Math.round( computed_price * (1 + sales_tax) ) + '), para cambiarte a este plan.');
      $('#plan_mp_table').show();
      $('#transfer_amount').val(Math.round(computed_price * (1 + sales_tax)));
      $('#transfer_amount_detail').text('$ ' + $('#transfer_amount').val());
      $('#wireChangeAmount').text('$ ' + $('#transfer_amount').val());

    }

    $('#new_plan_id').val(plan_id);

    if($('#changePlanBtnCol').length > 0)
    {
      var new_params = "/" + plan_id;
      var cut_str = "generate_plan_transaction";
      var curr_href = $('#changePlanBtnCol').attr('href');
      var cut_index = curr_href.indexOf(cut_str);
      cut_index += cut_str.length;
      curr_href = curr_href.substring(0, cut_index) + new_params;
      console.log("Acá");
      console.log(curr_href);
      $('#changePlanBtnCol').attr('href', curr_href);
      $('#changePlanBtnCol').show();
    }

    $('#changePlanModal').modal('show');
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

  $('#payBtn').on('click', function(e){
    if($('.mp_radio:checked').length < 1 || $('#amount_select').val() == "0")
    {
      swal({
        title: "Elige cantidad y medio de pago antes de pagar.",
        type: "error"
      });
      e.preventDefault();
    }
    $(this).attr('disabled', true);
    $(this).find('button').attr('disabled', true);
  });

  $('#reactivatePayBtn').on('click', function(e){
    if($('.reactivate_mp_radio:checked').length < 1)
    {
      swal({
        title: "Elige medio de pago antes de pagar.",
        type: "error"
      });
      e.preventDefault();
    }
    $(this).attr('disabled', true);
    $(this).find('button').attr('disabled', true);
  });

  $('#changePlanPayBtn').on('click', function(e){
    if($('.change_plan_mp_radio:checked').length < 1)
    {
      swal({
        title: "Elige un medio de pago primero.",
        type: "error"
      });
      e.preventDefault();
    }
    $(this).attr('disabled', true);
    $(this).find('button').attr('disabled', true);
  });

});
