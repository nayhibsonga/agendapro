// Panel Drag & Drop
function panelDragStart(e) {
	$(this).css('opacity', 0.4);  // this / e.target is the source node.

	dragPanel = this;

	e.dataTransfer.effectAllowed = 'move';
	e.dataTransfer.setData('text/html', this.innerHTML);
}

function panelDragOver (e) {
	if (e.preventDefault) {
		e.preventDefault();
	};
	e.dataTransfer.dropEffect = 'move';
	return false;
}

function panelDragEnter (e) {
	$(this).addClass('over');
}

function panelDragLeave (e) {
	$(this).removeClass('over');
}

function panelDrop (e) {
	console.warn('drop')
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefault) {
		e.preventDefault();
	};

	if (dragPanel != this) {
		dragPanel.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	panelNewOrder();

	return false;
}

function panelDragEnd (e) {
	$(this).css('opacity', 1);

	var panels = $('#accordion .panel');
	$.each(panels, function (key, panel) {
		panel.classList.remove('over');
	});
}

function panelNewOrder () {
	var categories = new Array();
	$.each($('#accordion .panel'), function (key, panel) {
		var panel_hash = {
			service_category: $(panel).children('.panel-heading').data('category'),
			order: key
		};
		categories.push(panel_hash);
	});
	console.log(categories);
}

var console = window.console;
var dragPanel = null;
$(function () {
	var panels = $('#accordion .panel');
	$.each(panels, function (key, panel) {
		panel.addEventListener('dragstart', panelDragStart, false);
		panel.addEventListener('dragenter', panelDragEnter, false);
		panel.addEventListener('dragover', panelDragOver, false);
		panel.addEventListener('dragleave', panelDragLeave, false);
		panel.addEventListener('drop', panelDrop, false);
		panel.addEventListener('dragend', panelDragEnd, false);
	});
});