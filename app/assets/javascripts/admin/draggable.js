function panelDragStart(e) {
	this.style.opacity = 0.4;  // this / e.target is the source node.

	dragPanel = this;

	e.dataTransfer.effectAllowed = 'move';
	e.dataTransfer.setData('text/html', this.innerHTML);
}

function panelDragOver (e) {
	if (e.preventDefaul) {
		e.preventDefaul();
	};
	e.dataTransfer.dropEffect = 'move';
	return false;
}

function panelDragEnter (e) {
	this.classList.add('over');
}

function panelDragLeave (e) {
	this.classList.remove('over');
}

function panelDrop (e) {
	console.warn('drop')
	if (e.stopPropagation) {
		e.stopPropagation();
	};
	if (e.preventDefaul) {
		e.preventDefaul();
	};

	if (dragPanel != this) {
		dragSrcEl.innerHTML = this.innerHTML;
    	this.innerHTML = e.dataTransfer.getData('text/html');
	};

	return false;
}

function panelDragEnd (e) {
	this.style.opacity = '1';

	var panels = document.querySelectorAll('#accordion .panel');
	[].forEach.call(panels, function (panel) {
		panel.classList.remove('over');
	});
}

var console = window.console;
var dradPanel = null;
$(function () {
	var panels = document.querySelectorAll('.panel');
	[].forEach.call(panels, function (panel) {
		panel.addEventListener('dragstart', panelDragStart, false);
		panel.addEventListener('dragenter', panelDragEnter, false);
		panel.addEventListener('dragover', panelDragOver, false);
		panel.addEventListener('dragleave', panelDragLeave, false);
		panel.addEventListener('drop', function (e) {alert()}, false);
		panel.addEventListener('dragend', panelDragEnd, false);
	});
});