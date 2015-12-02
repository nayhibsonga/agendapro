$(function() {
	$('#update_notifications_button').click(function(){
		$('#quick_add_step7').show();
		//$('#quick_add_step7').attr('disabled', false);
		scrollToAnchor('quick_add_step7');
	});
});


$(document).ready(function(){

	$('#notification_email_receptor_type').change(function () {
	    var val = $(this).val();
	    if (val == 1) {
	      	$('#local-notification').removeClass('hidden');
	      	if (!$('#provider-notification').hasClass('hidden')) {
	        	$('#provider-notification').addClass('hidden');
	        	uncheckCheckbox($('#provider-notification'));
	      	}
	    } else if (val == 2) {
	      	$('#provider-notification').removeClass('hidden');
	      	if (!$('#local-notification').hasClass('hidden')) {
	        	$('#local-notification').addClass('hidden');
	        	uncheckCheckbox($('#local-notification'));
	      	}
	    } else{
	      	if (!$('#provider-notification').hasClass('hidden')) {
	        	$('#provider-notification').addClass('hidden');
	        	uncheckCheckbox($('#provider-notification'));
	      	}
	      	if (!$('#local-notification').hasClass('hidden')) {
	        	$('#local-notification').addClass('hidden');
	        	uncheckCheckbox($('#local-notification'));
	      	}
	    }
	});

	$("#addNotificationBtn").on('click', function(e){

		e.preventDefault();

		var data = $("#new_notification_email").serializeArray();

		$.ajax({
			url: '/create_notification_email',
			type: 'post',
			dataType: 'json',
			data: data,
			error: function(response){

			},
			success: function(response){
				notification_email = response.notification_email;
				console.log(notification_email);
				console.log(response);
				$("#notification-emails-table").append(
					'<tr class="notification-email-row" notification_id="' + notification_email.id + '">' +
					'<td>' + notification_email.email +'</td>' +
					'<td>' + notification_email.receptor_type_text +'</td>' +
					'<td>' + notification_email.notification_text +'</td>' +
					'<td style="white-space: nowrap;">' +
                      '<button id="notification_email_delete_' + notification_email.id + '" class="btn btn-danger btn-xs notification-email-delete-btn"><i class="fa fa-trash-o"></i></button>' +
                    '</td>' +
                    '</tr>'
				);
			}
		});

	});

	$('body').on('click', '.notification-email-delete-btn', function(){
		var id = $(this).attr("id").split("_")[3];
		$.ajax({
			url: '/delete_notification_email',
			type: 'post',
			dataType: 'json',
			data: {id: id},
			error: function(response){

			},
			success: function(response){
				if(response.status != "error")
				{
					$('.notification-email-row[notification_id="' + id + '"]').remove();
				}
			}
		})
	});

});

function uncheckCheckbox (parent) {
  $.each(parent.find('input[type="checkbox"]'), function (i, checkbox) {
    $(checkbox).prop('checked', false);
  });
}
