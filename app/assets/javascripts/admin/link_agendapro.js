$(function () {
	$('input[name="formatRadio"]').change(function () {
		$('.active-radio').removeClass('active-radio').addClass('hidden');
		$('input[name="' + $(this).val() + '"]').closest('.radio').removeClass('hidden').addClass('active-radio');
		$('pre').empty();
	});

	$('input[name="sizeImageRadio"]').change(function () {
		$('input[name="sizeButtonRadio"]').prop('checked', false);
		$('input[name="sizeLinkRadio"]').prop('checked', false);
		var size = $(this).val().split('x');
		var extLink = '<a href="http://' + web_address + '.agendapro.cl" target="_blank" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;text-decoration: none;color: #428bca;"><img alt="AgendaPro" src="http://agendapro.cl/assets/logos/logo_mail.png" width="' + size[0] + '" height="' + size[1] + '" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;border: 0;vertical-align: middle;page-break-inside: avoid;max-width: 100%!important;"></a>';
		extLink = extLink.replace(/</g, '&lt;').replace(/>/g, '&gt;');
		$('pre').empty();
		$('pre').append(extLink);
	});

	$('input[name="sizeButtonRadio"]').change(function () {
		$('input[name="sizeImageRadio"]').prop('checked', false);
		$('input[name="sizeLinkRadio"]').prop('checked', false);
		var size = $(this).val();
		var extLink = '<a class="btn btn-agendapro-oscuro" href="http://' + web_address + '.agendapro.cl" target="_blank" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;text-decoration: none;color: #ffffff;display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.428571429;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;border: 1px solid transparent;border-radius: 4px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;background-color: rgba(27,115,112,1);border-color: rgba(24, 101, 99, 1);">Reserva Online</a>';
		if ($(this).val() == 'btn-lg') {
			extLink = '<a class="btn btn-agendapro-oscuro btn-lg" href="http://' + web_address + '.agendapro.cl" target="_blank" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;text-decoration: none;color: #ffffff;display: inline-block;padding: 10px 16px;margin-bottom: 0;font-size: 18px;font-weight: normal;line-height: 1.33;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;border: 1px solid transparent;border-radius: 6px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;background-color: rgba(27,115,112,1);border-color: rgba(24, 101, 99, 1);">Reserva Online</a>';
		}
		else if ($(this).val() == 'btn-sm') {
			extLink = '<a class="btn btn-agendapro-oscuro btn-sm" href="http://' + web_address + '.agendapro.cl" target="_blank" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;text-decoration: none;color: #ffffff;display: inline-block;padding: 5px 10px;margin-bottom: 0;font-size: 12px;font-weight: normal;line-height: 1.5;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;border: 1px solid transparent;border-radius: 3px;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;-o-user-select: none;user-select: none;background-color: rgba(27,115,112,1);border-color: rgba(24, 101, 99, 1);">¡Reserva Online!</a>';
		};
		extLink = extLink.replace(/</g, '&lt;').replace(/>/g, '&gt;');
		$('pre').empty();
		$('pre').append(extLink);
	});

	$('input[name="sizeLinkRadio"]').change(function () {
		$('input[name="sizeImageRadio"]').prop('checked', false);
		$('input[name="sizeButtonRadio"]').prop('checked', false);
		var extLink = '<a href="http://' + web_address + '.agendapro.cl" target="_blank" style="-webkit-box-sizing: border-box;-moz-box-sizing: border-box;box-sizing: border-box;text-decoration: none;color: #428bca;">Reserva Online</a>';
		extLink = extLink.replace(/</g, '&lt;').replace(/>/g, '&gt;');
		$('pre').empty();
		$('pre').append(extLink);
	});
});