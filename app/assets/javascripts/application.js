//= require bootstrap
//= require Alert
//= require ga

//por defecto:
//= require jquery_ujs
// require turbolinks
var alertDismiss;
$(function () {
	alertDismiss = setTimeout(function () {
		$('.alert').alert('close');
	}, 3000);
});
