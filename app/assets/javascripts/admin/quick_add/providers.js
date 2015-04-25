function saveLocation () {
	$.ajax({
	    type: 'POST',
	    url: '/quick_add/provider.json',
	    data: { "location": locationJSON },
	    dataType: 'json',
	    success: function (result){
			$('#load_location_spinner').show();
			$('#location_pills.nav-pills li').removeClass('active');
			if (typeURL == 'POST') {
				$('#new_location_pill').parent().before('<li><a href="#" id="location_pill_'+result.id+'">'+result.name+'<!--  <button id="location_delete_'+result.id+'" class="btn btn-danger btn-xs"><i class="fa fa-trash-o"></i></button> --></a></li>');
				$('#location_pill_'+result.id).click(function(event){
					event.preventDefault();
					$('#load_location_spinner').show();
					$('#location_pills.nav-pills li').removeClass('active');
					load_location(result.id);
				});
			}
			else {
				$('#location_pill_'+result.id).html(result.name);
			}
			$('#update_location_spinner').hide();
			$('#update_location_button').atrr('disabled', false);
			$('#next_location_button').atrr('disabled', false);
	    	new_location();
		},
		error: function (xhr){
		    var errors = $.parseJSON(xhr.responseText).errors;
		    var errorList = '';
			for (i in errors) {
				errorList += '<li>' + errors[i] + '</li>'
			}
			my_alert.showAlert(
				'<h3>Error</h3>' +
				'<ul>' +
					errorList +
				'</ul>'
			);
			$('#update_location_spinner').hide();
			$('#update_location_button').atrr('disabled', false);
			$('#next_location_button').atrr('disabled', false);
		}
	});
}

$(function() {
	$('#next_provider_button').click(function(){
		scrollToAnchor('quick_add_step5');
	});
});