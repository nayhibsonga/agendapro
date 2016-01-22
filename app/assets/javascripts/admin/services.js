var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

function buildDay (value) {
  $('#serviceTable').append(
    '<tr>' +
      '<th>' +
        '<div class="checkbox">' +
          '<label>' +
            '<input type="checkbox" name="dayStatus'+ value +'" id="dayStatusId'+ value +'" value="0" onchange="changeDayStatus('+ value +')"> ' + days[value - 1] + ':' +
          '</label>' +
        '</div>' +
      '</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control" id="openHourId'+ value +'" name="openHour'+ value +'" disabled="disabled">' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
              '<option value="04">04</option>' +
              '<option value="05">05</option>' +
              '<option value="06">06</option>' +
              '<option value="07">07</option>' +
              '<option value="08">08</option>' +
              '<option value="09" selected>09</option>' +
              '<option value="10">10</option>' +
              '<option value="11">11</option>' +
              '<option value="12">12</option>' +
              '<option value="13">13</option>' +
              '<option value="14">14</option>' +
              '<option value="15">15</option>' +
              '<option value="16">16</option>' +
              '<option value="17">17</option>' +
              '<option value="18">18</option>' +
              '<option value="19">19</option>' +
              '<option value="20">20</option>' +
              '<option value="21">21</option>' +
              '<option value="22">22</option>' +
              '<option value="23">23</option>' +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control" id="openMinuteId'+ value +'" name="openMinute'+ value +'" disabled="disabled">' +
              '<option value="00" selected>00</option>' +
              '<option value="15">15</option>' +
              '<option value="30">30</option>' +
              '<option value="45">45</option>' +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
      '<th>' +
        '<form class="form-inline" role="form">' +
          '<div class="form-group">' +
            '<select class="form-control" id="closeHourId'+ value +'" name="closeHour'+ value +'" disabled="disabled">' +
              '<option value="00">00</option>' +
              '<option value="01">01</option>' +
              '<option value="02">02</option>' +
              '<option value="03">03</option>' +
              '<option value="04">04</option>' +
              '<option value="05">05</option>' +
              '<option value="06">06</option>' +
              '<option value="07">07</option>' +
              '<option value="08">08</option>' +
              '<option value="09">09</option>' +
              '<option value="10">10</option>' +
              '<option value="11">11</option>' +
              '<option value="12">12</option>' +
              '<option value="13">13</option>' +
              '<option value="14">14</option>' +
              '<option value="15">15</option>' +
              '<option value="16">16</option>' +
              '<option value="17">17</option>' +
              '<option value="18" selected>18</option>' +
              '<option value="19">19</option>' +
              '<option value="20">20</option>' +
              '<option value="21">21</option>' +
              '<option value="22">22</option>' +
              '<option value="23">23</option>' +
            '</select>' +
          '</div> : ' +
          '<div class="form-group">' +
            '<select class="form-control" id="closeMinuteId'+ value +'" name="closeMinute'+ value +'" disabled="disabled">' +
              '<option value="00" selected>00</option>' +
              '<option value="15">15</option>' +
              '<option value="30">30</option>' +
              '<option value="45">45</option>' +
            '</select>' +
          '</div>' +
        '</form>' +
      '</th>' +
    '</tr>'
  );
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
    $.each(serviceTimesData, function(index,serviceTime) {
      var value = serviceTime.day_id;
      $('#dayStatusId'+ value).prop('checked', true);
      $('#dayStatusId'+ value).val(1);

      $('#openHourId'+ value).prop('disabled', false);
      $('#openMinuteId'+ value).prop('disabled', false);
      $('#closeHourId'+ value).prop('disabled', false);
      $('#closeMinuteId'+ value).prop('disabled', false);
      // Deseleccionar por defecto
      $('#openHourId' + value + ' > option:selected').removeAttr('selected');
      $('#openMinuteId' + value + ' > option:selected').removeAttr('selected');
      $('#closeHourId' + value + ' > option:selected').removeAttr('selected');
      $('#closeMinuteId' + value + ' > option:selected').removeAttr('selected');

      var openTime = new Date(Date.parse(serviceTime.open)).toUTCString().split(" ")[4].split(":");
      var closeTime = new Date(Date.parse(serviceTime.close)).toUTCString().split(" ")[4].split(":");

      $('#openHourId'+ value +' option[value="'+openTime[0]+'"]').attr("selected",true);
      $('#openMinuteId'+ value +' option[value="'+openTime[1]+'"]').attr("selected",true);
      $('#closeHourId'+ value +' option[value="'+closeTime[0]+'"]').attr("selected",true);
      $('#closeMinuteId'+ value +' option[value="'+closeTime[1]+'"]').attr("selected",true);
    });
  }
  else {
    for (var i = 0; i < 8; i++) {
      changeDayStatus(i);
      $('#dayStatusId' + i).prop('checked', true).val(1);
    };
  };
}

function changeDayStatus (value) {
  if ($('#dayStatusId'+ value).val() == 0) {
    $('#openHourId'+ value).prop('disabled', false);
    $('#openMinuteId'+ value).prop('disabled', false);
    $('#closeHourId'+ value).prop('disabled', false);
    $('#closeMinuteId'+ value).prop('disabled', false);
    $('#dayStatusId'+ value).val(1);
  }
  else if ($('#dayStatusId'+ value).val() == 1) {
    $('#openHourId'+ value).prop('disabled', true);
    $('#openMinuteId'+ value).prop('disabled', true);
    $('#closeHourId'+ value).prop('disabled', true);
    $('#closeMinuteId'+ value).prop('disabled', true);
    $('#dayStatusId'+ value).val(0);
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
    var service_time = {"open":"2000-01-01T"+ $('#openHourId'+enabledDays[i]).val() +":"+ $('#openMinuteId'+enabledDays[i]).val() +":00Z","close":"2000-01-01T"+ $('#closeHourId'+enabledDays[i]).val() +":"+ $('#closeMinuteId'+enabledDays[i]).val() +":00Z","day_id":parseInt(enabledDays[i])};
    service_times.push(service_time);
  }

  var serviceJSON  = {
  	"name": $('#service_name').val(),
  	"price": $('#service_price').val(),
  	"show_price": $('#service_show_price').prop('checked'),
  	"comission_value": $('#service_comission_vale').val(),
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
      var errors = $.parseJSON(xhr.responseText).errors;
      var errorList = '';
      for (i in errors) {
        errorList += '- ' + errors[i] + '\n\n';
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
