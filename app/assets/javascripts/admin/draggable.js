function dragStart (e) {
	$(this).css('opacity', 0.4)

	dragElemente = this;

	e.dataTransfer.effectAllowed = 'move';
	e.dataTransfer.setData('text/html', this.innerHTML);
}	

function dragOver (e) {
	if (e.preventDefault) {
		e.preventDefault();
	};
	e.dataTransfer.dropEffect = 'move';
	return false;
}

function dragEnter (e) {
	$(this).addClass('over');
}

function dragLeave (e) {
	$(this).removeClass('over');
}

function drop (e) {
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefault) {
		e.preventDefault();
	};

	var tbody = e.target.parentNode.parentNode;
	var resource = $(e.target.parentNode).data('resource')
	if (dragElemente != this) {
		dragElemente.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	if (resource == 'services') {
		serviceNewOrder(tbody);
	} else{
		categoryNewOrder(tbody);
	};

	return false;
}

function dragEnd (e) {
	$(this).css('opacity', 1);

	var rows = $('tbody tr');
	$.each(rows, function (key, row) {
		row.classList.remove('over');
	});
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

var dragElemente = null;
$(function () {
	var rows = $('tbody tr');
	$.each(rows, function (key, row) {
		row.addEventListener('dragstart', dragStart, false);
		row.addEventListener('dragenter', dragEnter, false);
		row.addEventListener('dragover', dragOver, false);
		row.addEventListener('dragleave', dragLeave, false);
		row.addEventListener('drop', drop, false);
		row.addEventListener('dragend', dragEnd, false);
	});
});