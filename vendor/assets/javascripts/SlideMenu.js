/**
 * The nav stuff
 */
(function( window ){
	
	'use strict';

	var body = document.body,
		mask = document.createElement("div"),
		toggleSlideLeft = document.querySelector( ".toggle-slide-left" ),
		toggleSlideRight = document.querySelector( ".toggle-slide-right" ),
		slideMenuLeft = document.querySelector( ".slide-menu-left" ),
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
		document.body.appendChild(mask);
		activeNav = "smr-open";
	} );

	/* hide active menu if mask is clicked */
	mask.addEventListener( "click", function(){
		$(body).removeClass(activeNav);
		activeNav = "";
		document.body.removeChild(mask);
	} );

	/* hide active menu if close menu button is clicked */
	[].slice.call(document.querySelectorAll(".close-menu")).forEach(function(el,i){
		el.addEventListener( "click", function(){
			$(body).removeClass(activeNav);
			activeNav = "";
			document.body.removeChild(mask);
		} );
	});
})( window );