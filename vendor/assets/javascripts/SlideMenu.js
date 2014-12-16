/**
 * The nav stuff
 */
(function( window ){
	
	'use strict';

	var body = document.body,
		mask = document.createElement("div"),
		// toggleSlideLeft = document.querySelector( ".toggle-slide-left" ),
		toggleSlideRight = document.querySelector( ".toggle-slide-right" ),
		// slideMenuLeft = document.querySelector( ".slide-menu-left" ),
		slideMenuRight = document.querySelector( ".slide-menu-right" ),
		activeNav
	;
	mask.className = "mask";

	/* slide menu left */
	// toggleSlideLeft.addEventListener( "click", function(){
	// 	$(body).addClass('sml-open');
	// 	document.body.appendChild(mask);
	// 	activeNav = "sml-open";
	// } );

	/* slide menu right */
	toggleSlideRight.addEventListener( "click", function(){
		$(body).addClass('smr-open');
		$('html').addClass('smr-open');
		document.body.appendChild(mask);
		activeNav = "smr-open";
	} );

	/* hide active menu if mask is clicked */
	mask.addEventListener( "click", function(){
		$(body).removeClass(activeNav);
		$('html').removeClass(activeNav);
		activeNav = "";
		document.body.removeChild(mask);
	} );

	/* hide active menu if close menu button is clicked */
	[].slice.call(document.querySelectorAll(".close-menu")).forEach(function(el,i){
		el.addEventListener( "click", function(){
			$(body).removeClass(activeNav);
			$('html').removeClass(activeNav);
			activeNav = "";
			document.body.removeChild(mask);
		} );
	});

	/* hide active menu if links are clicked */
	[].slice.call(document.querySelectorAll("nav.menu li a")).forEach(function(el,i){
		if (!$(el).hasClass('divider')) {
			el.addEventListener( "click", function(){
				$(body).removeClass(activeNav);
				$('html').removeClass(activeNav);
				activeNav = "";
				document.body.removeChild(mask);
				var href = $.attr(this, 'href');
				if (href.length > 0) {
					var element = href.substring(1);
					$('html, body').animate({
						scrollTop: $( element ).offset().top - 50
					}, 1000);
				};
			} );
		};
	});
})( window );