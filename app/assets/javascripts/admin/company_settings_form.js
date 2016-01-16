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

  $('.company-web-address').on('change', function() {
    var tmp = $('#company_web_address').val();
    tmp = tmp.toLowerCase();
    tmp = tmp.replace(/[áäâà]/gi, 'a'); //special a
    tmp = tmp.replace(/[éëêè]/gi, 'e'); //Special e
    tmp = tmp.replace(/[íïîì]/gi, 'i'); //Special i
    tmp = tmp.replace(/[óöôò]/gi, 'o'); //Special o
    tmp = tmp.replace(/[úüûù]/gi, 'u'); //Special u
    tmp = tmp.replace(/ñ/gi, 'n');  //Special ñ
    tmp = tmp.replace(/[^a-z0-9]/gi,'');
    $(this).val(tmp);
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
          swal({
            title: "Error",
            text: "Se produjeron los siguientes errores:\n" + errorList,
            type: "error"
          });
        },
      });
    };
  });

  $('.company-country-checkbox').change(function() {
    var t = $(this).attr('id');
    t = t.substr(0, t.lastIndexOf("_"));
    if ( $('#' + t + '_active').prop('checked') ) {
      $('#' + t + '_web_address').prop('disabled', false);
      $('#' + t + '_web_address').val($('#company_web_address').val());
    }
    else {
      $('#' + t + '_web_address').prop('disabled', true);
      $('#' + t + '_web_address').val('');
    }
  });

  if ($('#company_setting_activate_notes').prop('checked')) {
    $('#company_setting_preset_notes').closest('.form-group').removeClass('hidden');
  } else{
    $('#company_setting_preset_notes').closest('.form-group').addClass('hidden');
  };

  $('#company_setting_activate_notes').change(function () {
    var presetNotes = $('#company_setting_preset_notes').closest('.form-group');
    if ($(this).prop('checked')) {
      presetNotes.removeClass('hidden');
    } else{
      presetNotes.addClass('hidden');
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
    $('#staffCode .has-success').removeClass('has-success');
    $('#staffCode .fa.fa-check').removeClass('fa fa-check');
    $('#staffCode .has-error').removeClass('has-error');
    $('#staffCode .fa.fa-times').removeClass('fa fa-times');
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

  $('#notification_email_receptor_type').change(function () {
    var val = $(this).val();
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

  $('#NewStaffCode').click(function() {
    $('#staffCode form').attr('action', '/staff_codes');
    $('#staffCode form').attr('id', 'new_staff_code');
    $('#staffCode form input[name="_method"]').remove();
    $('#staff_code_staff').val('');
    $('#staff_code_code').val('');
    $('#staff_code_active').val(true);
  });

  $('.edit_staff_code_button').click(function(e) {
    $('#staffCode form').attr('action', '/staff_codes/' + $(e.currentTarget).data('id'));
    $('#staffCode form').attr('id', 'edit_staff_code_method_' + $(e.currentTarget).data('id'));
    if ($('#staffCode form input[name="_method"]').length < 1) {
      $('#staffCode form').append('<input name="_method" type="hidden" value="patch">');
    }
    $('#staff_code_staff').val($(e.currentTarget).data('staff'));
    $('#staff_code_code').val($(e.currentTarget).data('code'));
    $('#staff_code_active').val($(e.currentTarget).data('active'));
  });

  $('#new_cashier_button').click(function() {
    $('form.cashier_form').attr('action', '/cashiers');
    $('form.cashier_form').attr('id', 'new_cashier');
    $('form.cashier_form').removeClass('edit_cashier');
    $('form.cashier_form input[name="_method"]').remove();
    $('#cashier_name').val('');
    $('#cashier_active').attr('checked', true);
    $('#cashier_code').attr('checked', true);
    $('#cashierModal').modal('show');
  });

  $('.edit_cashier_button').click(function(e) {
    $('form.cashier_form').attr('action', '/cashiers/' + $(e.currentTarget).data('id'));
    $('form.cashier_form').attr('id', 'edit_cashier_' + $(e.currentTarget).data('id'));
    $('form.cashier_form').addClass('edit_cashier');
    if ($('form.cashier_form input[name="_method"]').length < 1) {
      $('form.cashier_form').append('<input name="_method" type="hidden" value="patch">');
    }
    $('#cashier_name').val($(e.currentTarget).data('name'));
    $('#cashier_active').attr('checked', $(e.currentTarget).data('active'));
    $('#cashier_code').val($(e.currentTarget).data('code'));
    $('#cashierModal').modal('show');
  });

  $('#new_attribute_button').on('click', function(){
    $('#attributeModal').modal('show');
  });

  $('#attribute_datatype').on('change', function(){
    if($(this).val() == "file")
    {
      $('.attribute-show-option').hide();
    }
    else
    {
      $('.attribute-show-option').show();
    }
  });

  $('.add_attribute_category_button').on('click', function(e){
    var attribute_id = $(e.currentTarget).data('attributeid');
    $('#existing_categories_subdiv').empty();
    $('#attribute_category_attribute_id').val(attribute_id)
    $.ajax({
      url: '/get_attribute_categories',
      method: 'get',
      dataType: 'json',
      data: {attribute_id: attribute_id},
      error: function(response){
        swal({
            title: "Error",
            text: "Se produjo un error",
            type: "error"
          });
      },
      success: function(response){
        $.each(response, function(i, attribute_category){

          if(attribute_category.category != "Otra")
          {

            $('#existing_categories_subdiv').append('<div class="attribute-category-div" attribute_category_id="' + attribute_category.id + '">' + attribute_category.category + '<a style="float: right;" class="btn btn-red btn-xs category-delete" data-confirm="¿Estás seguro de eliminar la categoría?" data-method="delete" data-remote="true" data-type="json" href="/attribute_categories/' + attribute_category.id + '" rel="nofollow"><i class="fa fa-trash-o"></i>&nbsp;Eliminar</a></div>');
          }
          else
          {
            $('#existing_categories_subdiv').append('<div class="attribute-category-div" attribute_category_id="' + attribute_category.id + '">' + attribute_category.category + '</div>');
          }

        });
      }
    })
    $('#attributeCategoryModal').modal('show');
  });

  $('.edit_attribute_btn').on('click', function(e){
    var attribute_id = $(e.currentTarget).data('attributeid');
    $('#editAttributeModal .modal-content').empty();
    $.ajax({
      url: '/attribute_edit_form',
      data: {id: attribute_id},
      method: 'get',
      error: function(response){
        swal({
          title: "Error",
          text: "Se produjo un error",
          type: "error"
        });
      },
      success: function(response){
        $('#editAttributeModal .modal-content').append(response);
        $('#editAttributeModal').modal('show');
      }
    })
  });

  $("#attribute_category_form").on("ajax:success", function(e, data, status, xhr){
    
    if(data.category != "Otra")
    {

      $('#existing_categories_subdiv').append('<div class="attribute-category-div" attribute_category_id="' + data.id + '">' + data.category + '<a style="float: right;" class="btn btn-red btn-xs category-delete" data-confirm="¿Estás seguro de eliminar la categoría?" data-method="delete" data-remote="true" data-type="json" href="/attribute_categories/' + data.id + '" rel="nofollow"><i class="fa fa-trash-o"></i>&nbsp;Eliminar</a></div>');
    }
    else
    {
      $('#existing_categories_subdiv').append('<div class="attribute-category-div" attribute_category_id="' + data.id + '">' + data.category + '</div>');
    }

    $('#attribute_category_category').val("");

    swal({
      title: "Éxito",
      text: "Categoría agregada.",
      type: "success"
    });
  }).on("ajax:error", function(e, xhr, status, error){
    console.log(xhr.responseText)
    swal({
      title: "Error",
      text: "Se produjo un error",
      type: "error"
    });
  });

  $('body').on("ajax:success", ".category-delete", function(e, data, status, xhr){
    console.log(data);
    var cat_id = data.id;
    $('.attribute-category-div[attribute_category_id="' + cat_id + '"]').remove();
    swal({
        title: "Éxito",
        text: "Categoría eliminada.",
        type: "success"
    });
  }).on("ajax:error", function(e, xhr, status, error){
    console.log(xhr.responseText)
    swal({
      title: "Error",
      text: "Se produjo un error",
      type: "error"
    });
  });


});

function uncheckCheckbox (parent) {
  $.each(parent.find('input[type="checkbox"]'), function (i, checkbox) {
    $(checkbox).prop('checked', false);
  });
}
