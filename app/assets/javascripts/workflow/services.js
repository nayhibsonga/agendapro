function loadStep1() {
	if ($('[name="localRadio"]').is(':checked')) {
		$('#services-selector').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
		var localId = $('input[name=localRadio]:checked').val();
		$.getJSON('/localServices', {location: localId}, function (servicesArray) {
			$('#services-selector').empty();
			$.each(servicesArray, function (key, services) {
				$.each(services, function (key, service) {
					$('#services-selector').append('<label>' +
							'<input type="radio" name="serviceRadio" value="' + service.id + '">' +
							'<p>' + service.name + '</p>' +
						'</label>'
					);
				});
			});
			$('[name="serviceRadio"]').on('click', function(event) {
				var serviceId = event.target.getAttribute('value');
				loadDescription(serviceId);
			});
		});
		return true;
	}
	return false;
}

function loadDescription (serviceId) {
	$('#services-description').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
	$.getJSON('/services/' + serviceId + '.json', function (service) {
		$('#services-description').html('');
		$('#services-description').html('<dl class="dl-horizontal"></dl>');
		$('.dl-horizontal').append('<dt>' + "Nombre" + '</dt><dd>' + service.name + '</dd>');
		$('.dl-horizontal').append('<dt>' + "Precio" + '</dt><dd>$' + service.price + '</dd>');
		$('.dl-horizontal').append('<dt>' + "Duración" + '</dt><dd>' + service.duration + ' Minutos</dd>');
		if(service.description) {
			$('.dl-horizontal').append('<dt>' + "Descripción" + '</dt><dd>' + service.description + '</dd>');
		}
	});
}

function loadStep2() {
	if($('[name="serviceRadio"]').is(':checked')){
		$('#staff-selector').html('<%= image_tag "ajax-loader.gif", :alt => "Loader" %>');
		var serviceId = $('input[name=serviceRadio]:checked').val();
		$.getJSON('/serviceProviders', {id: serviceId}, function (providers) {
			$('#staff-selector').empty();
			$.each(providers, function (key, provider) {
				$('#staff-selector').append('<label>' +
						'<input type="radio" name="staffRadio" value="' + provider.id + '">' +
						'<p>Provider: ' + provider.id + '</p>' +
					'</label>'
				);
			});
		});
		/*
		 * Ademas cargar el horario conjunto de los staffs.
		 * Al seleccionar un staff cargar el horario particular
		*/
		return true;
	}
	alert('Debe elegir un Servicio')
	return false;
}

function loadStep3() {
	alert('step 3')
	return true;
}

function loadStep4() {
	alert('step 4')
	return true;
}

function finalize() {
	alert('finalize')
	return true;
}