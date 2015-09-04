var anchor = window.location.hash;
if (anchor != "") {
  $('a[href="' + anchor + '"]')[0].click();
};

$(function () {
  $('#myTab a').click(function (e) {
    var title = $(this).data('title');
    var description = $(this).data('description');

    if (title.length > 0 && description.length > 0) {
      $('#title').html(title);
      $('#description').html(description);
    };
  });

  $('#company_web_address').on('change', function() {
    var tmp = $('#company_web_address').val();
    tmp = tmp.toLowerCase();
    tmp = tmp.replace(/[áäâà]/gi, 'a'); //special a
    tmp = tmp.replace(/[éëêè]/gi, 'e'); //Special e
    tmp = tmp.replace(/[íïîì]/gi, 'i'); //Special i
    tmp = tmp.replace(/[óöôò]/gi, 'o'); //Special o
    tmp = tmp.replace(/[úüûù]/gi, 'u'); //Special u
    tmp = tmp.replace(/ñ/gi, 'n');  //Special ñ
    tmp = tmp.replace(/[^a-z0-9]/gi,'');
    $('#company_web_address').val(tmp);
  });

  $("#company_logo").change(function (){
    if ($("#company_logo").valid()) {
      var src = $('#company-form img').attr("src");
      $('#company-form img').attr("src", "/assets/mobile/loading.gif");
      var formId = $('#company-form').prop('id');
      $.ajax({
        type: 'POST',
        url: '/quick_add/update_company',
        data: new FormData(document.getElementById(formId)),
        mimeType: 'multipart/form-data',
        contentType: false,
        processData: false,
        success: function (result) {
          d = new Date();
          $('#company-form img').attr("src", result+"?ts="+d.getTime());
          $("#company_logo").val('');
        },
        error: function (xhr) {
          $('#company-form img').attr("src", src);
          var errors = $.parseJSON(xhr.responseText).errors;
          var errorList = '';
          for (i in errors) {
            errorList += '* ' + errors[i] + '\n'
          }
          alert(
            'Error\n' +
            '--------' +
            errorList
          );
        },
      });
    };
  });

  if ($('#company_setting_can_edit').prop('checked')) {
    $('#company_setting_max_changes').closest('.form-group').removeClass('hidden');
  } else{
    $('#company_setting_max_changes').closest('.form-group').addClass('hidden');
  };

  $('#company_setting_can_edit').change(function () {
    var maxChange = $('#company_setting_max_changes').closest('.form-group');
    if ($(this).prop('checked')) {
      maxChange.removeClass('hidden');
    } else{
      maxChange.addClass('hidden');
    };
  });

  $('#fromEmail').on('hidden.bs.modal', function (e) {
    validator.resetForm();
    $('.has-success').removeClass('has-success');
    $('.fa.fa-check').removeClass('fa fa-check');
    $('.has-error').removeClass('has-error');
    $('.fa.fa-times').removeClass('fa fa-times');
  });

  $('#staffCode').on('hidden.bs.modal', function (e) {
    validator.resetForm();
    $('.has-success').removeClass('has-success');
    $('.fa.fa-check').removeClass('fa fa-check');
    $('.has-error').removeClass('has-error');
    $('.fa.fa-times').removeClass('fa fa-times');
  });

  if($('#company_setting_allows_online_payment').prop('checked')) {
    $(".account-info").removeClass("hidden");
    if($("#company_setting_bank :selected").text() == "Otro") {
      $("#other-bank").removeClass("hidden");
      $(".account-data").addClass("hidden");
    } else {
      $("#other-bank").addClass("hidden");
      $(".account-data").removeClass("hidden");
    }
  } else {
    $(".account-info").addClass("hidden");
    $("#other-bank").addClass("hidden");
  }

  if($('#company_setting_allows_online_payment').prop('checked')) {
    $(".account-info").removeClass("hidden");

    if($("#company_setting_bank :selected").text() == "Otro") {
      $("#other-bank").removeClass("hidden");
      $(".account-data").addClass("hidden");
    } else {
      $("#other-bank").addClass("hidden");
      $(".account-data").removeClass("hidden");
    }

    var mod_can = false;

    if($("#company_setting_online_cancelation_policy_attributes_cancelable").prop('checked')) {
      $(".cancel-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".cancel-div").addClass('hidden');
    }

    if($("#company_setting_online_cancelation_policy_attributes_modifiable").prop('checked')) {
      $(".modification-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".modification-div").addClass('hidden');
    }

    if(mod_can) {
      $('.min-hours-div').removeClass('hidden');
    } else {
      $('.min-hours-div').addClass('hidden');
    }
  } else {
    $(".account-info").addClass("hidden");
    $("#other-bank").addClass("hidden");
  }

  $("#company_setting_allows_online_payment").change(function(){
    if($('#company_setting_allows_online_payment').prop('checked')) {
      $(".account-info").removeClass("hidden");
      if($("#company_setting_bank :selected").text() == "Otro") {
        $("#other-bank").removeClass("hidden");
        $(".account-data").addClass("hidden");
      } else {
        $("#other-bank").addClass("hidden");
        $(".account-data").removeClass("hidden");
      }

      var mod_can = false;

      if($("#company_setting_online_cancelation_policy_attributes_cancelable").prop('checked')) {
        $(".cancel-div").removeClass('hidden');
        mod_can = true;
      } else {
        $(".cancel-div").addClass('hidden');
      }

      if($("#company_setting_online_cancelation_policy_attributes_modifiable").prop('checked')) {
        $(".modification-div").removeClass('hidden');
        mod_can = true;
      } else {
        $(".modification-div").addClass('hidden');
      }

      if(mod_can) {
        $('.min-hours-div').removeClass('hidden');
      } else {
        $('.min-hours-div').addClass('hidden');
      }
    } else {
      $("#other-bank").addClass("hidden");
      $(".account-info").addClass("hidden");
    }
  });

  $("#company_setting_bank").change(function(){
    if($("#company_setting_bank :selected").text() == "Otro") {
      $("#other-bank").removeClass("hidden");
      $(".account-data").addClass("hidden");
    } else {
      $("#other-bank").addClass("hidden");
      $(".account-data").removeClass("hidden");
    }
  });

  $("#company_setting_online_cancelation_policy_attributes_modifiable").change(function(){
    var mod_can = false;

    if($("#company_setting_online_cancelation_policy_attributes_cancelable").prop('checked')) {
      $(".cancel-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".cancel-div").addClass('hidden');
    }

    if($("#company_setting_online_cancelation_policy_attributes_modifiable").prop('checked')) {
      $(".modification-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".modification-div").addClass('hidden');
    }

    if(mod_can) {
      $('.min-hours-div').removeClass('hidden');
    } else {
      $('.min-hours-div').addClass('hidden');
    }
  });

  $("#company_setting_online_cancelation_policy_attributes_cancelable").change(function(){

    var mod_can = false;

    if($("#company_setting_online_cancelation_policy_attributes_cancelable").prop('checked')) {
      $(".cancel-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".cancel-div").addClass('hidden');
    }

    if($("#company_setting_online_cancelation_policy_attributes_modifiable").prop('checked')) {
      $(".modification-div").removeClass('hidden');
      mod_can = true;
    } else {
      $(".modification-div").addClass('hidden');
    }

    if(mod_can) {
      $('.min-hours-div').removeClass('hidden');
    } else {
      $('.min-hours-div').addClass('hidden');
    }
  });

  CKEDITOR.replace(company_setting_signature);

  $('#notification_email_receptor_type').change(function (e) {
    var val = $(e.target).val();
    if (val == 1) {
      $('#local-notification').removeClass('hidden');
      if (!$('#provider-notification').hasClass('hidden')) {
        $('#provider-notification').addClass('hidden');
        uncheckCheckbox($('#provider-notification'));
      };
    } else if (val == 2) {
      $('#provider-notification').removeClass('hidden');
      if (!$('#local-notification').hasClass('hidden')) {
        $('#local-notification').addClass('hidden');
        uncheckCheckbox($('#local-notification'));
      };
    } else{
      if (!$('#provider-notification').hasClass('hidden')) {
        $('#provider-notification').addClass('hidden');
        uncheckCheckbox($('#provider-notification'));
      };
      if (!$('#local-notification').hasClass('hidden')) {
        $('#local-notification').addClass('hidden');
        uncheckCheckbox($('#local-notification'));
      };
    };
  });
  $('#new_payment_method_button').click(function() {
    $('form.company_payment_method_form').attr('action', '/company_payment_methods');
    $('form.company_payment_method_form').attr('id', 'new_company_payment_method');
    $('form.company_payment_method_form').removeClass('edit_company_payment_method');
    $('form.company_payment_method_form input[name="_method"]').remove();
    $('#company_payment_method_name').val('');
    $('#company_payment_method_active').attr('checked', true);
    $('#company_payment_method_number_required').attr('checked', true);
    $('#payment_method').modal('show');
  });

  $('.edit_company_payment_button').click(function(e) {
    $('form.company_payment_method_form').attr('action', '/company_payment_methods/' + $(e.currentTarget).data('id'));
    $('form.company_payment_method_form').attr('id', 'edit_company_payment_method_' + $(e.currentTarget).data('id'));
    $('form.company_payment_method_form').addClass('edit_company_payment_method');
    if ($('form.company_payment_method_form input[name="_method"]').length < 1) {
      $('form.company_payment_method_form').append('<input name="_method" type="hidden" value="patch">');
    }
    $('#company_payment_method_name').val($(e.currentTarget).data('name'));
    $('#company_payment_method_active').attr('checked', $(e.currentTarget).data('active'));
    $('#company_payment_method_number_required').attr('checked', $(e.currentTarget).data('number-required'));
    $('#payment_method').modal('show');
  });

});

function uncheckCheckbox (parent) {
  $.each(parent.find('input[type="checkbox"]'), function (i, checkbox) {
    $(checkbox).prop('checked', false);
  });
}
