// $('input').on('itemAdded', function(event) {
//   // event.item: contains the item
// });
// $('input').on('beforeItemRemove', function(event) {
//   // event.item: contains the item
//   // event.cancel: set to true to prevent the item getting removed
// });


$(function() {
	$('#next_service_button').click(function(){
		scrollToAnchor('fieldset_step4');
	});
});