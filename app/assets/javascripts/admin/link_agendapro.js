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
		var extLink = '<a class="btn btn-agendapro-oscuro" href="http://' + web_address + '.agendapro.cl" target="_blank" style="background: transparent;color: #fff;text-decoration: none;display: inline-block;padding: 6px 12px;margin-bottom: 0;font-size: 14px;font-weight: normal;line-height: 1.42857143;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;background-image: linear-gradient(to bottom, #1B7370 0%, #0E4D4B 100%);border: 1px solid transparent;border-radius: 4px;background-color: #1B7370;border-color: #2b669a;text-shadow: 0 -1px 0 rgba(0, 0, 0, .2);-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);filter: progid:DXImageTransform.Microsoft.gradient(enabled = false);background-repeat: repeat-x;">Reserva Online</a>';
		if ($(this).val() == 'btn-lg') {
			extLink = '<a class="btn btn-agendapro-oscuro btn-lg" href="http://' + web_address + '.agendapro.cl" target="_blank" style="background: transparent;color: #fff;text-decoration: none;display: inline-block;padding: 10px 16px;margin-bottom: 0;font-size: 18px;font-weight: normal;line-height: 1.33;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;background-image: linear-gradient(to bottom, #1B7370 0%, #0E4D4B 100%);border: 1px solid transparent;border-radius: 6px;background-color: #1B7370;border-color: #2b669a;text-shadow: 0 -1px 0 rgba(0, 0, 0, .2);-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);filter: progid:DXImageTransform.Microsoft.gradient(enabled = false);background-repeat: repeat-x;">Reserva Online</a>';
		}
		else if ($(this).val() == 'btn-sm') {
			extLink = '<a class="btn btn-agendapro-oscuro btn-sm" href="http://' + web_address + '.agendapro.cl" target="_blank" style="background: transparent;color: #fff;text-decoration: none;display: inline-block;padding: 5px 10px;margin-bottom: 0;font-size: 12px;font-weight: normal;line-height: 1.5;text-align: center;white-space: nowrap;vertical-align: middle;cursor: pointer;-webkit-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;background-image: linear-gradient(to bottom, #1B7370 0%, #0E4D4B 100%);border: 1px solid transparent;border-radius: 3px;background-color: #1B7370;border-color: #2b669a;text-shadow: 0 -1px 0 rgba(0, 0, 0, .2);-webkit-box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);box-shadow: inset 0 1px 0 rgba(255, 255, 255, .15), 0 1px 1px rgba(0, 0, 0, .075);filter: progid:DXImageTransform.Microsoft.gradient(enabled = false);background-repeat: repeat-x;">Reserva Online</a>';
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