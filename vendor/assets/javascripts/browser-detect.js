// Líneas comentadas para que no moleste en versión móvil, dado que el desarrollo hizo compatibles móviles.
// Revisar el tema de Blink y Webkit en detalle para ver futuras alertas.
$(function () {
	if ($.browser.msie) {
		if ($.browser.versionNumber <= 9) {
			msieMessage();
		}
	}
	else if ($.browser.webkit) {
		if ($.browser.name == "chrome") {
			if ($.browser.versionNumber <= 25) {
				webkitMessage();
			}
		}
		else if ($.browser.name == "safari") {
			if ($.browser.versionNumber <= 3) {
				webkitMessage();
			}
		}
		else if ($.browser.name == "opera") {
			if ($.browser.versionNumber <= 12) {
				webkitMessage();
			}
		}
		// else {
		// 	otherMessage();
		// }
	}
	else if ($.browser.mozilla) {
		if ($.browser.versionNumber <= 15) {
			mozillaMessage();
		}
	}
	// else if ($.browser.ipad || $.browser.iphone || $.browser["windows phone"] || $.browser.android) {
	// 	mobileMessage();
	// }
	// else {
	// 	otherMessage();
	// }
});

function msieMessage () {
	var message =	'<p>' +
						'La página puede no ser compatible con su explorador. ' +
						'Le recomendamos instalar <a href="https://www.google.com/intl/es/chrome/browser/" target="_blank">Google Chrome</a> o <a href="https://www.mozilla.org/es-CL/firefox/new/" target="_blank">Mozilla Firefox</a>' +
					'</p>';
	showNotice(message);
}

function webkitMessage () {
	var message =	'<p>' +
						'La página puede no ser compatible con su versión actual. ' +
						'Le recomendamos actualizar a la ultima versión.' +
					'</p>';
	showNotice(message);
}

function mozillaMessage () {
	var message =	'<p>' +
						'La página puede no ser compatible con su versión actual. ' +
						'Le recomendamos actualizar a la ultima versión.' +
					'</p>';
	showNotice(message);
}

function mobileMessage () {
	var message =	'<p>' +
						'La página puede no ser compatible con su dispositivo móvil.'
					'</p>';
	showNotice(message);
}

function otherMessage () {
	var message =	'<p>' +
						'La página puede no ser compatible con este explorador. ' +
						'Le recomendamos instalar <a href="https://www.google.com/intl/es/chrome/browser/" target="_blank">Google Chrome</a> o <a href="https://www.mozilla.org/es-CL/firefox/new/" target="_blank">Mozilla Firefox</a>' +
					'</p>';
	showNotice(message);
}

function generateAlert () {
	var btn = $('<button type="button" data-dismiss="alert" aria-hidden="true">&times;</button>');
	btn.addClass('close');

	var notice = $('<div></div>');
	notice.addClass('alert alert-danger alert-dismissable');
	notice.append(btn);

	return notice;
}

function showNotice (message) {
	var notice = generateAlert();
	notice.append(message);

	$('header').append(notice);
}