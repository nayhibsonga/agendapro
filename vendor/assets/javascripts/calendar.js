function Calendar (source, getData) {

	// Default Values
	var months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
	var days = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
	var sources = {
		source: '',
		data: {
			date: ''
		}
	}
	var week;
	var clickEvent;

	// Generate Calendar
	var generateCalendar = function (date) {
		$('.columna-dia').remove();
		$('.clear').remove();
		clickEvent = null;

		var now = date || new Date();
		var today = now.getDay() - 1;
		if (today < 0) {
			today = 6;
		}

		// Week calculation
		var offset = 0 - today;
		var monday, sunday;
		for (var i = 0; i < 7; i++, offset++) {
			var weekDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
			weekDay.setDate(now.getDate() + offset);

			if (i == 0) {
				monday = weekDay;
			}
			else if (i == 6) {
				sunday = weekDay;
			}

			// Generate Day
			generateDay(weekDay, sources);
		};

		// Tittle calculation
		generateTittle(monday, sunday);

		$('.horario').append('<div class="clear"></div>');

		return now;
	}

	// Tittle calculation
	var generateTittle = function (monday, sunday) {
		var sameYear = (monday.getFullYear() == sunday.getFullYear());
		var sameMonth = (monday.getMonth() == sunday.getMonth());
		var tittle = 'Semana del ' + monday.getDate();
		if (sameYear) {
			if (!sameMonth) {
				tittle += ' ' + months[monday.getMonth()] + ' al ' + sunday.getDate() + ' ' + months[sunday.getMonth()];
			}
			else {
				tittle +=  ' al ' + sunday.getDate() + ' ' + months[monday.getMonth()]
			}
		}
		else {
			tittle += ' ' + months[monday.getMonth()] + '/' + monday.getFullYear() + ' al ' + sunday.getDate() + ' ' + months[sunday.getMonth()] + '/' + sunday.getFullYear();
		}
		$('.tittle').text(tittle);
	}

	// Generate Day
	var generateDay = function (weekDay, sources) {
		sources.data.date = weekDay.toLocaleDateString();

		var pos = weekDay.getDay() - 1;
		if (pos < 0) {
			pos = 6;
		}
		var columnDay = $('<div>', {
			'class': 'columna-dia',
			'data-date': weekDay.toLocaleDateString()
		});
		columnDay.append('<div class="dia-semana">' + days[pos] + ' ' + weekDay.getDate() + '</div>');

		// Generate Hours
		generateHours(columnDay, sources);

		columnDay.append('<div class="clear"></div>');

		// Mark today
		var today = new Date();
		if (today.toLocaleDateString() == weekDay.toLocaleDateString()) {
			columnDay.addClass('columna-hoy');
		}
		$('.horario').append(columnDay);
	}

	// Generate Hours
	var generateHours = function (columnDay, sources) {
		$.getJSON(sources.source, sources.data, function (data, status) {
			$.each(data, function (key, hours) {
				var div = $('<div>', {
					'class': 'bloque-hora',
					'data-start': hours.hour.start,
					'data-end': hours.hour.end
				});
				switch (hours.status) {
					case 'available':
						div.addClass('hora-disponible');
						var span = $('<span>').text(hours.hour.start + ' - ' + hours.hour.end);
						div.append(span);
						break;
					case 'occupied':
						div.addClass('hora-ocupada');
						var span = $('<span>').text(hours.hour.start + ' - ' + hours.hour.end);
						div.append(span);
						break;
					case 'empty':
						div.addClass('hora-vacia');
						div.append('<span></span>')
						break;
					default:
						div.addClass('hora-vacia');
						var span = $('<span>').text(hours.hour.start + ' - ' + hours.hour.end);
						div.append(span);
						break;
				}
				div.click(function (e) {
					var element = $(e.currentTarget);
					if (element.hasClass('hora-disponible')) {
						// Activate block
						$('.hora-activo').addClass('hora-disponible').removeClass('hora-activo');
						element.removeClass('hora-disponible').addClass('hora-activo');

						// Event
						var details = {
							time: new Date(),
							message: 'Hour ' + element.data('start') + ' - ' + element.data('end') + ' click on day ' + element.parent().data('date'),
							date: element.parent().data('date'),
							start: element.data('start'),
							end: element.data('end'),
							objectDate: parseDate(element.parent().data('date'), element.data('start')),
							status: hours.status
						};
						$.event.trigger({
							type: 'hourClick',
							time: details.time,
							message: details.message,
							date: details.date,
							start: details.start,
							end: details.end,
							status: details.status,
							objectDate: details.objectDate
						});
						clickEvent = details;
					}
				});
				columnDay.append(div);
			});
			if (!data.length) {
				columnDay.remove();
			}
		});
	}

	var parseDate = function (date, start) {
		start = start || '00:00';
		var month = date.substring(0, date.indexOf('/')) - 1;
		date = date.substring(date.indexOf('/') + 1);
		var day = date.substring(0, date.indexOf('/'));
		var year = date.substring(date.indexOf('/') + 1);
		var hour = start.substring(0, start.indexOf(':'));
		var minutes = start.substring(start.indexOf(':') + 1);

		return new Date(year, month, day, hour, minutes);
	}

	// Auxiliar methods
	this.rebuild = function (source, getData) {
		sources = {
			source: '/jsontest',
			data: {
				date: ''
			}
		}

		// Default values
		sources.source = source || sources.source;
		getData = getData || {};
		sources.data = $.extend(true, sources.data, getData);

		week = generateCalendar();
	}

	this.getClickDetails = function () {
		return clickEvent;
	}

	$(function () {
		// Default values
		sources.source = source || sources.source;
		getData = getData || {};
		sources.data = $.extend(true, sources.data, getData);

		week = generateCalendar();

		// Buttons
		$('#prev').click(function () {
			var day = new Date(week.getFullYear(), week.getMonth(), week.getDate());
			day.setDate(week.getDate() - 7);
			week = generateCalendar(day);
		});
		$('#next').click(function () {
			var day = new Date(week.getFullYear(), week.getMonth(), week.getDate());
			day.setDate(week.getDate() + 7);
			week = generateCalendar(day);
		});
	});
}