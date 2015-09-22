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

	groupNewOrder(tbody);

	return false;
}

// Group Drag & Drop
function groupNewOrder (tbody) {
	var groups = new Array();
	$.each($(tbody).children(), function (key, tr) {
		var row_hash = {
			provider_group: $(tr).children("td:first").data('group'),
			order: key
		};
		groups.push(row_hash);
	});
	$.post(
		'/change_groups_order',
		{groups_order: groups},
		function (data) {
			$.each(data, function (key, result) {
				if (result.status != 'Ok') {
					$('.content-fix').prepend(
						'<div class="alert alert-danger alert-dismissable">' +
							'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
							'No se pudo guardar el cambio de orden de: ' + result.provider_group +
						'</div>'
					);
				};
			});
		}
	);
}