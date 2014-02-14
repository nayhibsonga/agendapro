$(document).ready(function() {
	//Collapsing Header Effect
	var nav = $('.collapsing_header header');    
    $(window).scroll(function () {
        if ($(this).scrollTop() > 400) {
            nav.addClass("absolute");
        } else {
            nav.removeClass("absolute");
        }
    });
    
	var window_top = $(window).scrollTop();
    if (window_top > 400) {
        nav.addClass("absolute");
    } else {
        nav.removeClass("absolute");
    }  
});