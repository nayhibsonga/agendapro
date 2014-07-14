jQuery(document).ready(function ($) {

	var slideCount = $('#local_slider ul li').length;
	var slideWidth = $('#local_slider ul li').width();
	var slideHeight = $('#local_slider ul li').height() - 2;
	var sliderUlWidth = slideCount * slideWidth;
	
	$('#local_slider').css({ width: '100%', height: slideHeight });
	
	$('#local_slider ul').css({ width: sliderUlWidth, marginLeft: - slideWidth });
	
	$('#local_slider ul li:last-child').prependTo('#local_slider ul');

	function moveLeft() {
		$('#local_slider ul').animate({
			left: + slideWidth
		}, 200, function () {
			$('#local_slider ul li:last-child').prependTo('#local_slider ul');
			$('#local_slider ul').css('left', '');
		});
	};

	function moveRight() {
		window.console.log('move')
		$('#local_slider ul').animate({
			left: - slideWidth
		}, 200, function () {
			$('#local_slider ul li:first-child').appendTo('#local_slider ul');
			$('#local_slider ul').css('left', '');
		});
	};

	$('#local_slider a.control_prev').click(function () {
		moveLeft();
	});

	$('#local_slider a.control_next').click(function () {
		window.console.log('move')
		moveRight();
	});
});