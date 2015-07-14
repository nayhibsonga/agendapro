var ajaxRequest;
var bookSummaries;
function PromoCalendar (source, getData) {

	// Default Values
	var months = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];
	var days = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
	var sources = {
		source: '',
		data: {
			date: ''
		}
	}

	var week;
	var clickEvent;
	var onload = true;

	// Generate Calendar
	var generatePromoCalendar = function (date) {

		onload = false;

		$('#staff-selector-spinner').show();
		$('#staff-selector > .list-group-item').hide();
		$('.days-row').hide();
		$('.horario').html('<div style="color: rgb(204, 204, 204); text-align: center;"><i class="fa fa-spinner fa-spin fa-lg"></i></div>');

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
		};

		if (ajaxRequest != null) {
			ajaxRequest.abort();
		}
		sources.data.date = formatPromoDate(monday);
		
		ajaxRequest = $.getJSON(sources.source, sources.data, function (data, status) {
			$('.days-row').html(data.days_row);
			$('.horario').html(data.panel_body);
			bookSummaries = [];
			for(i=0; i<data.book_summaries.length; i++)
			{
				bookSummaries.push(data.book_summaries[i]);
			}
			$('.bloque-hora').click(function (e) {
				var element = $(e.currentTarget);
				if(element.hasClass('hora-ocupada'))
				{
					return false;
				}
				if (element.hasClass('hora-disponible') || element.hasClass('hora-promocion')) {
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
						provider: element.data('provider'),
						provider_id: element.data('providerid'),
						objectDate: parsePromoDate(element.parent().data('date'), element.data('start')),
						index: element.data('index')
						// status: hours.status
					};
					$.event.trigger({
						type: 'hourClick',
						time: details.time,
						message: details.message,
						date: details.date,
						start: details.start,
						end: details.end,
						provider: details.provider,
						provider_id: details.provider_id,
						// status: details.status,
						objectDate: details.objectDate,
						index: details.index
					});
					clickEvent = details;
				}
			});

			// Tittle calculation
			generatePromoTitle(monday, sunday);

			$('.days-row').show();
			calculatePromoWidth();
			$('#next').removeAttr('disabled');
			$('#prev').removeAttr('disabled');
			$.event.trigger({
				type: 'calendarBuilded'
			});
			$('#foo4').trigger('updateSizes');
			$('#staff-selector-spinner').hide();
			$('#staff-selector > .list-group-item').show();
		});

		return now;
	}

	function getPromoScrollbarWidth() {
	    var outer = document.createElement("div");
	    outer.style.visibility = "hidden";
	    outer.style.width = "100px";
	    outer.style.msOverflowStyle = "scrollbar"; // needed for WinJS apps

	    document.body.appendChild(outer);

	    var widthNoScroll = outer.offsetWidth;
	    // force scrollbars
	    outer.style.overflow = "scroll";

	    // add innerdiv
	    var inner = document.createElement("div");
	    inner.style.width = "100%";
	    outer.appendChild(inner);        

	    var widthWithScroll = inner.offsetWidth;

	    // remove divs
	    outer.parentNode.removeChild(outer);

	    return widthNoScroll - widthWithScroll;
	}

	// Tittle calculation
	var generatePromoTitle = function (monday, sunday) {
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

	// Generate Week
	var available_hour;
	var generatePromoWeek = function (monday) {

		if (ajaxRequest != null) {
			ajaxRequest.abort();
		}
		sources.data.date = formatPromoDate(monday);
		
		ajaxRequest = $.getJSON(sources.source, sources.data, function (data, status) {
			available_hour = false;

			$(".days-row").empty();

			$.each(data, function(day, day_blocks){
				var date = parsePromoDate(day);
				var dayNumber = date.getDay();
				if(day_blocks.length)
				{
					var weekNumber = date.getDate();
					$(".days-row").append('<div class="dia-semana">' + days[dayNumber] + ' ' + weekNumber + '</div>');
				}
			});



			var pos = 0;
			$.each(data, function (day, day_blocks) {
				var date = parsePromoDate(day);
				var dayNumber = date.getDay();
				// Generate Day
				if(day_blocks.length) {
					var columnDay = $('<div>', {
						'class': 'columna-dia',
						'data-date': day
					});
					var weekNumber = date.getDate();
					//columnDay.append('<div class="dia-semana">' + days[dayNumber] + ' ' + weekNumber + '</div>');

					// Generate Hours
					generatePromoHours(columnDay, day_blocks);

					columnDay.append('<div class="clear"></div>');

					// Mark Today
					var today = new Date();
					var todayString = today.getFullYear() + '-' + correctPromoNumber(today.getMonth() + 1) + '-' + correctPromoNumber(today.getDate());
					if(todayString == day) {
						columnDay.addClass('columna-hoy');
					}
					$('.horario').append(columnDay);
				}
				pos += 1;
			});

			if (onload && !available_hour) {
				$('#next').click();
			}

			$('.horario').append('<div class="clear"></div>');
			calculatePromoWidth();
			$('#next').removeAttr('disabled');
			$('#prev').removeAttr('disabled');
			$.event.trigger({
				type: 'calendarBuilded'
			});
			$('#foo4').trigger('updateSizes');
		});
		$('#staff-selector-spinner').hide();
		$('#staff-selector > .list-group-item').show();
	}

	// Generate Hours
	var generatePromoHours = function (columnDay, day_blocks) {
		$.each(day_blocks, function (key, hours) {
			var div = $('<div>', {
				'class': 'bloque-hora',
				'data-start': hours.hour.start,
				'data-end': hours.hour.end,
				'data-provider': hours.hour.provider,
				'data-bookings': hours.hour.bookings
			});
			switch (hours.status) {
				case 'past':
					div.addClass('hora-pasada');
					var span = $('<span>').text(hours.hour.start + ' - ' + hours.hour.end);
					div.append(span);
					break;
				case 'available':
					div.addClass('hora-disponible');
					var span = $('<span>').text(hours.hour.start + ' - ' + hours.hour.end);
					div.append(span);
					available_hour = true;
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
						provider: element.data('provider'),
						objectDate: parsePromoDate(element.parent().data('date'), element.data('start')),
						status: hours.status
					};
					$.event.trigger({
						type: 'hourClick',
						time: details.time,
						message: details.message,
						date: details.date,
						start: details.start,
						end: details.end,
						provider: details.provider,
						status: details.status,
						objectDate: details.objectDate
					});
					clickEvent = details;
				}
			});
			columnDay.append(div);
		});
	}

	// Auxiliar methods
	var parsePromoDate = function (date, start) {
		start = start || '00:00';

		if(date===undefined)
		{
			return new Date();
		}

		var year = date.substring(0, date.indexOf('-'));
		date = date.substring(date.indexOf('-') + 1);
		var month = date.substring(0, date.indexOf('-')) - 1;
		date = date.substring(date.indexOf('-') + 1);
		var day = date;
		var hour = start.substring(0, start.indexOf(':'));
		var minutes = start.substring(start.indexOf(':') + 1);

		return new Date(year, month, day, hour, minutes);
	}

	var calculatePromoWidth = function () {
		var count = $('.columna-dia').length;
		var width = (100 / count);
		$('.columna-dia').css('width', width + '%');

		var width2 = $(".horario")[0].clientWidth/count;
		$('.dia-semana').css('width', width2);

		$('.dia-semana').last().css('width', $(".horario")[0].clientWidth/count - 1);
	}

	var correctPromoNumber = function (number) {
		if (number < 10) {
			return '0' + number;
		}
		else {
			return number;
		}
	}

	var formatPromoDate = function (date) {
		return date.getFullYear() + '-' + correctPromoNumber(date.getMonth() + 1) + '-' + correctPromoNumber(date.getDate());
	}

	this.rebuild = function (source, getData) {
		var day = parsePromoDate(getData['date'], '00:00');

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
		week = generatePromoCalendar(day);
		onload = true;
	}

	this.getClickDetails = function () {
		return clickEvent;
	}

	$(function () {
		// Default values
		sources.source = source || sources.source;
		getData = getData || {};
		sources.data = $.extend(true, sources.data, getData);
		onload = true;

		week = generatePromoCalendar();

		// Buttons
		$('#prev').click(function () {
			$('#prev').attr('disabled', true);
			$('#next').attr('disabled', true);
			var day = new Date(week.getFullYear(), week.getMonth(), week.getDate());
			day.setDate(week.getDate() - 7);
			onload = false;
			week = generatePromoCalendar(day);
		});
		$('#next').click(function () {
			$('#prev').attr('disabled', true);
			$('#next').attr('disabled', true);
			var day = new Date(week.getFullYear(), week.getMonth(), week.getDate());
			day.setDate(week.getDate() + 7);
			onload = false;
			week = generatePromoCalendar(day);
		});
	});
}
