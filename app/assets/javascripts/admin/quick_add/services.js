// $('input').on('itemAdded', function(event) {
//   // event.item: contains the item
// });
// $('input').on('beforeItemRemove', function(event) {
//   // event.item: contains the item
//   // event.cancel: set to true to prevent the item getting removed
// });


$(function() {
	$('#service_categories_input').on('itemAdded', function(event) {
	  window.console.log(event);
	  event.item.id = 1;
	  window.console.log(event.item);
	});

	$('#next_service_button').click(function(){
		scrollToAnchor('quick_add_step4');
	});
});