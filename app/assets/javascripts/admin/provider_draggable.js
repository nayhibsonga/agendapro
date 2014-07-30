
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

	providerNewOrder(tbody);
	return false;
}

// Service Drag & Drop
function providerNewOrder (tbody) {
	var providers = new Array();
	$.each($(tbody).children(), function (key, tr) {
		var row_hash = {
			provider: $(tr).children().first().data('provider'),
			order: key
		};
		providers.push(row_hash);
	});
	$.post(
		'/change_providers_order',
		{providers_order: providers},
		function (data) {
			$.each(data, function (key, result) {
				if (result.status != 'Ok') {
					$('.content-fix').prepend(
						'<div class="alert alert-danger alert-dismissable">' +
							'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
							'No se pudo guardar el cambio de orden de: ' + result.provider +
						'</div>'
					);
				};
			});
		}
	);
}