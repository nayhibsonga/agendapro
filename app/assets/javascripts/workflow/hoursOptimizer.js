// Generals
var serviceTitle = "Elegir servicio y staff<br><small>Elige los servicios y prestadores para encontrar el mejor horario para realizarlos</small>";
var serviceButton = "Agregar otro servicio";
var hourTitle = "Resultado de la busqueda<br><small>Selecciona una fecha y hora</small>";
var hourButton = "Ver mas resultados";

// Functions
function loadServiceModal () {
  $('#serviceOptimizer').empty();
  $('#optimizerTitle').html(serviceTitle);
  $('#addButton > span').html(serviceButton);
  loadService();

  $('#addButton').off('click'); // Unbind click event
  $('#addButton').click(function (e) {
    loadService();
  }); // Bind click event
}

function loadService () {
  $('#serviceOptimizer').append('<p class="text-center"><i class="fa fa-spinner fa-spin fa-lg"></i></p>');
  var localId = $('#selectedLocal').data('local').id;
  $.getJSON('/local_services', {location: localId}, function (categorized_services) {
    var selectData = '';
    $.each(categorized_services, function (key, service_hash) {
      var category = service_hash.category;
      var services = '';
      $.each(service_hash.services, function (key, service) {
        services += '<option value="' + service.id + '">' + service.name + '</option>';
      });
      selectData += '<optgroup label="' + category + '">' + services + '</optgroup>';
    });

    $('#serviceOptimizer').append(
      '<div class="form-group">' +
        '<label for="serviceOptimizerSelector" class="col-xs-2 control-label">Servicio</label>' +
        '<div class="col-xs-10">' +
          '<select class="form-control" name="serviceOptimizerSelector">' +
            selectData +
          '</select>' +
        '</div>' +
        '<label for="providerOptimizerSelector" class="col-xs-2 control-label">Prestador</label>' +
        '<div class="col-xs-10">' +
          '<select class="form-control" name="providerOptimizerSelector"></select>' +
        '</div>' +
      '</div>'
    );

    $('select[name="serviceOptimizerSelector"]:last').change(function (e) {
      loadStaff(this);
    });

    loadStaff('select[name="serviceOptimizerSelector"]:last');

    $('#serviceOptimizer > p').remove();
  });
}

function loadStaff (selector) {
  var serviceId = $(selector).val();
  var localId = $('#selectedLocal').data('local').id;
  var providerPreference = $('#providerPreference').data('provider-preference');

  var providerSelector = $(selector).closest('.form-group').find('select[name="providerOptimizerSelector"]');
  $.getJSON('/providers_services', {id: serviceId, local: localId}, function (providers) {
    providerSelector.attr('disabled', true);
    providerSelector.empty();

    if (providerPreference != 1) {
      if (providers.length > 1) {
        providerSelector.append(
          '<option value="0">Sin Preferencia</option>'
        );
      }
    }
    if (providerPreference != 2) {
      $.each(providers, function (key, provider) {
        providerSelector.append(
          '<option value="' + provider.id + '">' + provider.public_name + '</option>'
        );
      });
    }

    providerSelector.attr('disabled', false);
  });
}

$(function () {
  $('#hoursOptimizer').on('show.bs.modal', function (e) {
    loadServiceModal();
  });
});
