//= require jquery-migrate-1.2.1
//= require bootstrap.min
//= require jquery_ujs
//= require Alert
//= require cocoon
//= require ga

$(window).load(function() {
	var contentPercent = 99.95 - 100*$('#sidebar').width()/$('#sidebar').offsetParent().width();
	$('#admin-content').width(contentPercent+'%');

	$('a#closetab').click(function() {
		var contentPercent = 99.95 - 100*$('#sidebar').width()/$('#sidebar').offsetParent().width();
		$('#admin-content').width(contentPercent.toString()+'%');
	});
});

window.onresize = function(event) {
    var contentPercent = 99.9 - 100*$('#sidebar').width()/$('#sidebar').offsetParent().width();
	$('#admin-content').width(contentPercent.toString()+'%');
};