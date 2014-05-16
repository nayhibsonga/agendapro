function drop (e) {
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefault) {
		e.preventDefault();
	};

	var tbody = $(e.target).closest('tbody');
	/*var resource = $(e.target.parentNode).data('resource')*/
	if (dragElemente != this) {
		dragElemente.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	categoryNewOrder(tbody);

	return false;
}

// Category Drag & Drop
function categoryNewOrder (tbody) {
	var categories = new Array();
	$.each($(tbody).children(), function (key, tr) {
		var row_hash = {
			service_category: $(tr).children().first().data('category'),
			order: key
		};
		categories.push(row_hash);
	});
	$.post(
		'/change_categories_order',
		{category_order: categories},
		function (data) {
			$.each(data, function (key, result) {
				if (result.status != 'Ok') {
					$('.content-fix').prepend(
						'<div class="alert alert-danger alert-dismissable">' +
							'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
							'<strong>Error!</strong> No se pudo guardar el cambio de: ' + result.service_category +
						'</div>'
					);
				};
			});
		}
	);
}