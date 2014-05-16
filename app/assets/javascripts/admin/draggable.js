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

function dragEnd (e) {
	$(this).css('opacity', 1);

	var rows = $('tbody tr');
	$.each(rows, function (key, row) {
		row.classList.remove('over');
	});
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