
function drop (e) {
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefault) {
		e.preventDefault();
	};

	var tbody = $(e.target).closest('tbody');
	if (dragElemente != this) {
		dragElemente.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	serviceNewOrder(tbody);
	return false;
}

// Service Drag & Drop
function serviceNewOrder (tbody) {
	var services = new Array();
	$.each($(tbody).children(), function (key, tr) {
		var row_hash = {
			service: $(tr).children().first().data('service'),
			order: key
		};
		services.push(row_hash);
	});
	$.post(
		'/change_services_order',
		{services_order: services},
		function (data) {
			$.each(data, function (key, result) {
				if (result.status != 'Ok') {
					$('.content-fix').prepend(
						'<div class="alert alert-danger alert-dismissable">' +
							'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
							'<strong>Error!</strong> No se pudo guardar el cambio de: ' + result.service +
						'</div>'
					);
				};
			});
		}
	);
}