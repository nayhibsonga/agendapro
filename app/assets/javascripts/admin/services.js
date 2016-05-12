var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
var hourOptions = '<option value="00">00</option>'+
    '<option value="01">01</option>'+
    '<option value="02">02</option>'+
    '<option value="03">03</option>'+
    '<option value="04">04</option>'+
    '<option value="05">05</option>'+
    '<option value="06">06</option>'+
    '<option value="07">07</option>'+
    '<option value="08">08</option>'+
    '<option value="09">09</option>'+
    '<option value="10">10</option>'+
    '<option value="11">11</option>'+
    '<option value="12">12</option>'+
    '<option value="13">13</option>'+
    '<option value="14">14</option>'+
    '<option value="15">15</option>'+
    '<option value="16">16</option>'+
    '<option value="17">17</option>'+
    '<option value="18">18</option>'+
    '<option value="19">19</option>'+
    '<option value="20">20</option>'+
    '<option value="21">21</option>'+
    '<option value="22">22</option>'+
    '<option value="23">23</option>';
var minuteOptions = '<option value="00">00</option>'+
    '<option value="05">05</option>'+
    '<option value="10">10</option>'+
    '<option value="15">15</option>'+
    '<option value="20">20</option>'+
    '<option value="25">25</option>'+
    '<option value="30">30</option>'+
    '<option value="35">35</option>'+
    '<option value="40">40</option>'+
    '<option value="45">45</option>'+
    '<option value="50">50</option>'+
    '<option value="55">55</option>';

function buildDay (value) {
  $('#serviceTable').append(
    '<tr>' +
      '<th>' +
        '<div class="checkbox">' +
          '<label>' +
            '<input type="checkbox" name="dayStatus'+ value +'" id="dayStatusId'+ value +'" value="0" onchange="changeDayStatus('+ value +')" class="dayCheckbox"> ' + days[value - 1] + ':' +
          '</label>' +
        '</div>' +
      '</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="openHourId'+ value +'" name="openHour'+ value +'" disabled="disabled">' +
              hourOptions +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="openMinuteId'+ value +'" name="openMinute'+ value +'" disabled="disabled">' +
              minuteOptions +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="closeHourId'+ value +'" name="closeHour'+ value +'" disabled="disabled">' +
              hourOptions +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="closeMinuteId'+ value +'" name="closeMinute'+ value +'" disabled="disabled">' +
              minuteOptions +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
      '<th></th>' +
    '</tr>'
  );
}

function addBreak (value, openTime, closeTime) {
  if ($('tr.break'+value).length > 0) {
    breakCount =  +$('tr.break' + value + ':last').find('a').attr('id').replace(value+'removeBreak','') + 1;
  }
  else {
    breakCount = 1
  }
  var position;
  if ($('.break' + value).length > 0) {
    position = $('.break' + value + ':last');
  }
  else {
    position = $('#dayStatusId' + value).closest('tr');
  }
  position.after(
    '<tr class="break' + value + '">' +
      '<th>Descanso:</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="'+value+'openHourId'+ breakCount+'" name="'+value+'openHour'+ breakCount+'">' +
              hourOptions +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="'+value+'openMinuteId'+breakCount+'" name="'+value+'openMinute'+breakCount+'">' +
              minuteOptions +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="'+value+'closeHourId'+breakCount+'" name="'+value+'closeHour'+breakCount+'">' +
              hourOptions +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control time-select" id="'+value+'closeMinuteId'+breakCount+'" name="'+value+'closeMinute'+breakCount+'">' +
              minuteOptions +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
      '<th>' +
        '<a id="'+value+'removeBreak'+breakCount+'" class="btn btn-red"><i class="fa fa-trash-o"></i></a>' +
      '</th>' +
    '</tr>'
  );

  $('#'+value+'removeBreak'+breakCount).click(function(event) {
    $(event.target).closest('tr').remove();
  });
  if (openTime != null){
    $('#'+value+'openHourId'+breakCount+' option[value="'+openTime[0]+'"]').attr("selected",true);
    $('#'+value+'openMinuteId'+breakCount+' option[value="'+openTime[1]+'"]').attr("selected",true);
  }
  if (closeTime != null) {
    $('#'+value+'closeHourId'+breakCount+' option[value="'+closeTime[0]+'"]').attr("selected",true);
    $('#'+value+'closeMinuteId'+breakCount+' option[value="'+closeTime[1]+'"]').attr("selected",true);
  }
}

function categoryChange() {
  if ($('#categoryCheckboxId').val() == 1) {
    $('#categoryCheckboxId').val(0);
    $('#service_service_category_id').prop('disabled', false);
    $('#service_service_category_id').closest('.form-group').removeClass('hidden');
    $('#service_service_category_attributes_name').val('');
    $('#service_service_category_attributes_name').prop('disabled', true);
    $('#service_service_category_attributes_name').closest('.form-group').addClass('hidden');
  }
  else if ($('#categoryCheckboxId').val() == 0) {
    $('#categoryCheckboxId').val(1);
    $('#service_service_category_attributes_name').prop('disabled', false);
    $('#service_service_category_attributes_name').closest('.form-group').removeClass('hidden');
    $('#service_service_category_id').val('');
    $('#service_service_category_id').prop('disabled', true);
    $('#service_service_category_id').closest('.form-group').addClass('hidden');
  }
}

function serviceGroup () {
  if ($('#service_group_service').is(':checked')) {
    $('#service_capacity').closest('.form-group').removeClass('hidden');
    $('#foo5').trigger('updateSizes');
    $('#service_capacity').attr('disabled', false);
  }
  else {
    $('#service_capacity').closest('.form-group').addClass('hidden');
    $('#service_capacity').attr('disabled', true);
  }
}

function serviceSessions() {
  if($("#service_has_sessions").is(':checked')){
    $('#service_sessions_amount').closest('.form-group').removeClass('hidden');
    $('#foo5').trigger('updateSizes');
    $('#service_sessions_amount').attr('disabled', false);
  }
  else{
    $('#service_sessions_amount').closest('.form-group').addClass('hidden');
    $('#service_sessions_amount').attr('disabled', true);
  }
}

function initialize() {
  for(var i = 1; i < 8; ++i) {
    buildDay(i);
  }

  if ( $('#id_data').length > 0 ) {
    var serviceTimesData = $('#service_times_data').data('service-times');
    var breaksArray = [0,0,0,0,0,0,0];
    $.each(serviceTimesData, function(index,serviceTime) {
      breaksArray[(serviceTime.day_id - 1)] += 1;
    });
    for (i in breaksArray) {
      if (breaksArray[i] > 0) {
        var arrayCounter = 0;
        for (var j=0;j<i;j++) {
          arrayCounter += breaksArray[j];
        }
        var value = serviceTimesData[arrayCounter].day_id;
        $('#dayStatusId'+ value).prop('checked', true);
        $('#dayStatusId'+ value).val(1);
        $('#dayStatusId'+value).closest('tr').children().last().append('<a id="addBreakdiv'+value+'" onclick="addBreak('+value+')" class="btn btn-green"><i class="fa fa-plus"></i></a>');

        $('#openHourId'+ value).prop('disabled', false);
        $('#openMinuteId'+ value).prop('disabled', false);
        $('#closeHourId'+ value).prop('disabled', false);
        $('#closeMinuteId'+ value).prop('disabled', false);
        var openTime = new Date(Date.parse(serviceTimesData[arrayCounter].open)).toUTCString().split(" ")[4].split(":");
        $('#openHourId'+ value +' option[value="'+openTime[0]+'"]').attr("selected",true);
        $('#openMinuteId'+ value +' option[value="'+openTime[1]+'"]').attr("selected",true);
        for (var j=arrayCounter;j<arrayCounter+breaksArray[i] - 1;j++) {
          var openTime = new Date(Date.parse(serviceTimesData[j].close)).toUTCString().split(" ")[4].split(":");
          var closeTime = new Date(Date.parse(serviceTimesData[j+1].open)).toUTCString().split(" ")[4].split(":");
          addBreak(value, openTime, closeTime);
        }
        var closeTime = new Date(Date.parse(serviceTimesData[arrayCounter+breaksArray[i]-1].close)).toUTCString().split(" ")[4].split(":");
        $('#closeHourId'+ value +' option[value="'+closeTime[0]+'"]').attr("selected",true);
        $('#closeMinuteId'+ value +' option[value="'+closeTime[1]+'"]').attr("selected",true);
      }
    }
  }
  else {
    for (var i = 0; i < 8; i++) {
      changeDayStatus(i);
      $('#dayStatusId' + i).prop('checked', true).val(1);
    };
  };

  serviceGroup();
}

function changeDayStatus (value) {
  if ($('#dayStatusId'+ value).val() == 0) {
    $('#openHourId'+ value).prop('disabled', false);
    $('#openMinuteId'+ value).prop('disabled', false);
    $('#closeHourId'+ value).prop('disabled', false);
    $('#closeMinuteId'+ value).prop('disabled', false);
    $('#dayStatusId'+ value).val(1);
    $('#dayStatusId'+value).closest('tr').children().last().append('<a id="addBreakdiv'+value+'" class="btn btn-green"><i class="fa fa-plus"></i></a>');
    $('#addBreakdiv'+value).click(function() {
      addBreak(value);
    });
  }
  else if ($('#dayStatusId'+ value).val() == 1) {
    $('#openHourId'+ value).prop('disabled', true);
    $('#openMinuteId'+ value).prop('disabled', true);
    $('#closeHourId'+ value).prop('disabled', true);
    $('#closeMinuteId'+ value).prop('disabled', true);
    $('#dayStatusId'+ value).val(0);
    $('#addBreakdiv'+value).remove();
  }
}

function servJSON() {
  var enabledProviders = [];
  $('input[name="service[service_provider_ids][]"]').each( function() {
    if ($(this).prop('checked')) {
      enabledProviders.push($(this).val());
    }
  });
  var enabledResources = [];
  $('input[name="service[resource_ids][]"]').each( function() {
    if ($(this).prop('checked')) {
      enabledResources.push($(this).val());
    }
  });
  var enabledDays = [];
  for(var i = 1; i < 8; ++i) {
    if ($('#dayStatusId'+ i).val() == 1) {
      enabledDays.push($('#dayStatusId'+ i).attr('id').slice(-1));
    }
  }
  var service_times = [];
  for (i in enabledDays) {
    day = enabledDays[i];
    if ($('tr.break'+day).length > 0) {
      breaks = [];
      $('tr.break'+day).each( function() {
        breaks.push([$(this).find('.form-control')[0].value+":"+$(this).find('.form-control')[1].value, $(this).find('.form-control')[2].value+":"+$(this).find('.form-control')[3].value]);
      });
      breaks = breaks.sort();
      var service_time = {"open":"2000-01-01T"+ $('#openHourId'+day).val() +":"+ $('#openMinuteId'+day).val() +":00Z","close":"2000-01-01T"+ breaks[0][0] +":00Z","day_id":parseInt(day)};
      service_times.push(service_time);
      for (j in breaks) {
        if (j < breaks.length - 1) {
          var service_time = {"open":"2000-01-01T"+ breaks[+j][1] +":00Z","close":"2000-01-01T"+ breaks[+j+1][0] +":00Z","day_id":parseInt(day)};
          service_times.push(service_time);
        }
      }
      var service_time = {"open":"2000-01-01T"+ breaks[breaks.length - 1][1] +":00Z","close":"2000-01-01T"+ $('#closeHourId'+day).val() +":"+ $('#closeMinuteId'+day).val() +":00Z","day_id":parseInt(day)};
      service_times.push(service_time);
    }
    else {
      var service_time = {"open":"2000-01-01T"+ $('#openHourId'+day).val() +":"+ $('#openMinuteId'+day).val() +":00Z","close":"2000-01-01T"+ $('#closeHourId'+day).val() +":"+ $('#closeMinuteId'+day).val() +":00Z","day_id":parseInt(day)};
      service_times.push(service_time);
    }
  }

  var serviceJSON  = {
    "name": $('#service_name').val(),
    "price": $('#service_price').val(),
    "show_price": $('#service_show_price').prop('checked'),
    "comission_value": $('#service_comission_value').val(),
    "comission_option": $('#service_comission_option').val(),
    "duration": $('#service_duration').val(),
    "outcall": $('#service_outcall').prop('checked'),
    "has_discount": $('#service_has_discount').prop('checked'),
    "discount": $('#service_discount').val(),
    "online_payable": $('#service_online_payable').val(),
    "must_be_paid_online": $('#service_must_be_paid_online').val(),
    "description": $('#service_description').val(),
    "online_booking": $('#service_online_booking').prop('checked'),
    "group_service": $('#service_group_service').prop('checked'),
    "capacity": $('#service_capacity').val(),
    "has_sessions": $('#service_has_sessions').prop('checked'),
    "sessions_amount": $('#service_sessions_amount').val(),
    "service_category_attributes": {"company_id": $('#service_service_category_company_id').val(), "id": $('#service_service_category_id').val()},
    "service_category_id": $('#service_service_category_id').val(),
    "service_provider_ids": enabledProviders,
    "resource_ids": enabledResources,
    "service_times_attributes": service_times,
    "time_restricted": $('#service_time_restricted').prop('checked')
  };
  return serviceJSON;
}

function saveService() {
  var serviceJSON = servJSON();
  var defaults = {
    data: { service: serviceJSON },
    dataType: 'json',
    success: function(service){
      document.location.href = '/services/';
    },
    error: function(xhr){

      console.log(xhr);
      var errors = $.parseJSON(xhr.responseText);
      var errorList = '';
      for (i in errors) {
        errorList += i + ":\n"
        for(j = 0; j < errors[i].length; j++)
        {
          errorList += errors[i][j] + '\n';
        }
        errorList += "\n";
      }
      swal({
        title: "Error",
        text: "Se produjeron los siguientes errores:\n\n" + errorList,
        type: "error"
      });
    }
  };

  if ( $('#id_data').length > 0 ) {
    var serviceId = $('#id_data').data('id');
    var option = {
      type: "PATCH",
      url: '/services/'+ JSON.stringify(serviceId) +'.json'
    };
  }
  else {
    var option = {
      type: "POST",
      url: '/services.json'
    };
  };
  var options = $.extend({}, defaults, option);
  $.ajax(options);
}

$(function() {
  $('form input, form select').bind('keypress keydown keyup', function(e){
      if(e.keyCode == 13) {
          e.preventDefault();
        }
    });

  initialize();

  $('#saveService').click(function() {
    saveService();
    return false;
  });

  $('#saveServiceTimes').click(function() {
    saveService();
    return false;
  });

  $('#service_service_category_attributes_name').prop('disabled', true);
  $('#service_group_service').click(function (e) {
    serviceGroup();
  });
  $('#service_has_sessions').click(function (e) {
    serviceSessions();
  });
  $('#categoryCheckboxId').click(function (e) {
    categoryChange();
  });
  if ($('#service_group_service').is(':checked')) {
    $('#service_capacity').closest('.form-group').removeClass('hidden');
    $('#foo5').trigger('updateSizes');
  }
  if ($('#service_has_sessions').is(':checked')) {
    $('#service_sessions_amount').closest('.form-group').removeClass('hidden');
    $('#service_sessions_amount').attr('disabled', false);
    $('#foo5').trigger('updateSizes');
  }
  if ($('#service_outcall').prop('checked')) {
    $('#outcallTip').removeClass('hidden');
  }
  $('input.check_boxes').each(function () {
    var prop = true;
    $(this).parents('.panel-body').find('input.check_boxes').each( function () {
      prop = prop && $(this).prop('checked');
    });
    $(this).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
  });
  $('input[name="selectLocation"]').change(function (event) {
    var id = $(event.target).attr('id').replace('selectLocation', '');
    $('#location' + id).find('input.check_boxes').each( function () {
      if ($(event.target).prop('checked')) {
        $(this).prop('checked', true);
      }
      else {
        $(this).prop('checked', false);
      }
    });
  });
  $('input.check_boxes').change(function (event) {
    var prop = true;
    $(event.target).parents('.panel-body').find('input.check_boxes').each( function () {
      prop = prop && $(this).prop('checked');
    });
    $(event.target).parents('.panel').find('input[name="selectLocation"]').prop('checked', prop);
  });

  $('input.check_boxes').each(function () {
    var prop = true;
    $(this).parents('.panel-body').find('input.check_boxes').each( function () {
      prop = prop && $(this).prop('checked');
    });
    $(this).parents('.panel').find('input[name="selectResourceCategory"]').prop('checked', prop);
  });
  $('input[name="selectResourceCategory"]').change(function (event) {
    var id = $(event.target).attr('id').replace('selectResourceCategory', '');
    $('#resource_category' + id).find('input.check_boxes').each( function () {
      if ($(event.target).prop('checked')) {
        $(this).prop('checked', true);
      }
      else {
        $(this).prop('checked', false);
      }
    });
  });

  $('input.check_boxes').change(function (event) {
    var prop = true;
    $(event.target).parents('.panel-body').find('input.check_boxes').each( function () {
      prop = prop && $(this).prop('checked');
    });
    $(event.target).parents('.panel').find('input[name="selectResourceCategory"]').prop('checked', prop);
  });
  $('#service_outcall').change(function() {
    if (!$('#service_outcall').prop('checked')) {
      $('#outcallTip').addClass('hidden');
    }
    else {
      $('#outcallTip').removeClass('hidden');
    }
  });

  $('#saveServiceCategryButton').click(function () {
    if ($('#new_service_category').valid()) {
      var btn = $(this)
      btn.button('loading')
      $.ajax({
        type: 'POST',
        url: '/service_categories.json',
        data: { "service_category": { "name": $('#service_category_name').val() } },
        dataType: 'json',
        success: function(service_category){
          $('#service_service_category_id').append('<option value="'+service_category.id+'">'+service_category.name+'</option>');
          $('#service_service_category_id option[value="'+service_category.id+'"]').prop('selected', true);
          $('#serviceCategoryModal').modal('hide');
        },
        error: function(xhr){
          var errors = $.parseJSON(xhr.responseText).errors;
          var errores = '';
          for (i in errors) {
            errores += '*' + errors[i] + '\n';
          }
          swal({
            title: "Error",
            text: "Se produjeron los siguientes errores:\n" + errores,
            type: "error"
          });
        },
      }).always(function () {
        btn.button('reset');
        $('#service_category_name').val('');
      });
    };
  });
  $('#service_company_id').change(function() {
    $.getJSON('/service_categories', { company_id: $('#service_company_id').val() }, function (service_categories) {

      $('#service_service_category_id').find('option').remove().end();
      $.each(service_categories, function (key, service_category) {
        $('#service_service_category_id').append(
          '<option value="' + service_category.id + '">' + service_category.name + '</option>'
        );
      });
      $('#region').prepend(
        '<option></option>'
      );
    });
  });

  $('#serviceCategoryModal').on('hidden.bs.modal', function (e) {
    validator.resetForm();
    $('.has-success').removeClass('has-success');
    $('.fa.fa-check').removeClass('fa fa-check');
    $('.has-error').removeClass('has-error');
    $('.fa.fa-times').removeClass('fa fa-times');
  });

  /*$('#service_online_payable').on('change', function(e){
    if($(this).prop('checked'))
    {
      $('#must_be_paid_div').show();
    }
    else
    {
      $("#service_must_be_paid_online").prop('checked', false);
      $("#must_be_paid_div").hide();
    }
  });*/

  var radios = $('input[name=online_payable_options]');
  radios.on('change', function(e) {
    pay_option = $('input[name=online_payable_options]:checked').val();

    if(pay_option == "no_pay")
    {
      $("#service_online_payable").val("0");
      $("#service_must_be_paid_online").val("0");
    }
    else if(pay_option == "may_pay")
    {
      $("#service_online_payable").val("1");
      $("#service_must_be_paid_online").val("0");
    }
    else if(pay_option == "must_pay")
    {
      $("#service_online_payable").val("1");
      $("#service_must_be_paid_online").val("1");
    }

    console.log($('input[name=online_payable_options]:checked').val());
  });

});
