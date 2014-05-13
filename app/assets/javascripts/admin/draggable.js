// Panel Drag & Drop
// function panelDragStart (e) {
// 	movePanel = true;
// 	$(this.parentNode).css('opacity', 0.4);  // this / e.target is the source node.

// 	dragPanel = this.parentNode;

// 	e.dataTransfer.effectAllowed = 'move';
// 	e.dataTransfer.setData('text/html', this.parentNode.innerHTML);
// }

// function panelDragOver (e) {
// 	if (e.preventDefault) {
// 		e.preventDefault();
// 	};
// 	e.dataTransfer.dropEffect = 'move';
// 	return false;
// }

// function panelDragEnter (e) {
// 	if (movePanel) {
// 		$(this.parentNode).addClass('over');
// 	};
// }

// function panelDragLeave (e) {
// 	if (movePanel) {
// 		$(this.parentNode).removeClass('over');
// 	};
// }

// function panelDrop (e) {
// 	if (e.stopPropagation) {
// 		e.stopPropagation();
// 	};
// 	if (e.preventDefault) {
// 		e.preventDefault();
// 	};

// 	if (movePanel && dragPanel != this.parentNode) {
// 		dragPanel.innerHTML = this.parentNode.innerHTML;
//     	this.parentNode.innerHTML = e.dataTransfer.getData('text/html');
// 	};

// 	// panelNewOrder();

// 	return false;
// }

// function panelDragEnd (e) {
// 	movePanel = false;
// 	var panels = $('#accordion .panel');
// 	$.each(panels, function (key, panel) {
// 		panel.classList.remove('over');
// 		$(panel).css('opacity', 1);
// 	});
// }

// function panelNewOrder () {
// 	var categories = new Array();
// 	$.each($('#accordion .panel'), function (key, panel) {
// 		var panel_hash = {
// 			service_category: $(panel).children('.panel-heading').data('category'),
// 			order: key
// 		};
// 		categories.push(panel_hash);
// 	});
// 	$.post(
// 		'/change_categories_order',
// 		{category_order: categories},
// 		function (data) {
// 			$.each(data, function (key, result) {
// 				if (result.status != 'Ok') {
// 					$('.content-fix').prepend(
// 						'<div class="alert alert-danger alert-dismissable">' +
// 							'<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
// 							'<strong>Error!</strong> No se pudo guardar el cambio de: ' + result.service_category +
// 						'</div>'
// 					);
// 				};
// 			});
// 		}
// 	);
// }

// Row Drag & Drop
function rowDragStart (e) {
	$(this).css('opacity', 0.4)

	dragRow = this;

	e.dataTransfer.effectAllowed = 'move';
	e.dataTransfer.setData('text/html', this.innerHTML);
}	

function rowDragOver (e) {
	if (e.preventDefault) {
		e.preventDefault();
	};
	e.dataTransfer.dropEffect = 'move';
	return false;
}

function rowDragEnter (e) {
	$(this).addClass('over');
}

function rowDragLeave (e) {
	$(this).removeClass('over');
}

function rowDrop (e) {
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefault) {
		e.preventDefault();
	};

	var tbody = e.target.parentNode.parentNode;
	if (dragRow != this) {
		dragRow.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	rowNewOrder(tbody);

	return false;
}

function rowDragEnd (e) {
	$(this).css('opacity', 1);

	var rows = $('tbody tr');
	$.each(rows, function (key, row) {
		row.classList.remove('over');
	});
}

function rowNewOrder (tbody) {
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

var console = window.console;
// var dragPanel = null;
// var movePanel = false;
var dragRow = null;
// var moveRow = false;
$(function () {
	// var panels = $('.panel .panel-heading');
	// $.each(panels, function (key, panel) {
	// 	panel.addEventListener('dragstart', panelDragStart, false);
	// 	panel.addEventListener('dragenter', panelDragEnter, false);
	// 	panel.addEventListener('dragover', panelDragOver, false);
	// 	panel.addEventListener('dragleave', panelDragLeave, false);
	// 	panel.addEventListener('drop', panelDrop, false);
	// 	panel.addEventListener('dragend', panelDragEnd, false);
	// });

	var rows = $('tbody tr');
	$.each(rows, function (key, row) {
		row.addEventListener('dragstart', rowDragStart, false);
		row.addEventListener('dragenter', rowDragEnter, false);
		row.addEventListener('dragover', rowDragOver, false);
		row.addEventListener('dragleave', rowDragLeave, false);
		row.addEventListener('drop', rowDrop, false);
		row.addEventListener('dragend', rowDragEnd, false);
	});
});