	function saveData(){
		
			 var first_name = $("#first_name").val();
	  var last_name = $("#last_name").val();
	   var email = $("#email").val();
	    var phone = $("#phone").val();
		var notes =$("#notes").val();
		var service_id = $("#service_id").val();
		var staff_id = $("#staff_id").val();
			   var selectedValues = $('#service_id').val();
		
	   if(first_name==''){
		alert('first name is required');
		 $('#first_name').focus();
		return;   
	   }
	    if(last_name==''){
		alert('last name is required');
		$('#last_name').focus();
		return;   
	   }
	   
	   if (!is_email(email)) {
        
            alert('valid email is required');
			$('#email').focus();
            return;
        }
		if(phone==''){
		alert('phone is required');
		$('#phone').focus();
		return;   
	   }
	   
	    if(service_id==null){
		alert('service is required');
		
		return;   
	   }

	  		
	   if(staff_id==''){
		alert('staff is required');
		
		return;   
	   }
	   
	   
	 $.ajax({
            url: "index.php?task=booking_ismultiplegroupservices&ids="+selectedValues,
			 type: 'POST',
            cache: false
        }).done(function (result) {
			if(result==0){
				 var $form = $("#booking_form");
        // let's select and cache all the fields
        $inputs = $form.find("input, select, button, textarea"),
        // serialize the data in the form
		
        serializedData = $form.serialize();
		
		
		serializedData += "&ids=" + selectedValues;
				  
				   $.ajax({
        type: 'POST',
        url: 'index.php?task=booking_add',
         data: serializedData,
        cache: false,
        success: function(result) {
			
			$('#calendar').fullCalendar('removeEvents');
		$('#calendar').fullCalendar( 'addEventSource', 'index.php?task=booking_jsonweek&staff_id='+<?php echo $staff_id; ?> );
			$("#dialog").dialog("close");
            
        }
		 });
			}else{
				  alert('Only one service is required when select group service');
            		return;
			}
        });
	}
	
	
		function showForm(id){
		$("#dialogConfirm").dialog("close");
		location_id = $("#txtLocation").val();
		staff_id = $("#txtStaff").val();
		date =$("#datepick").val();
		
		$.ajax({
			type: 'POST',
				data: { date:date,location_id:location_id,staff_id:staff_id,id:id},
				url: "index.php?task=booking_addbooking",
				success: function(data){
				$("#dialog").html(data);
			}   
			});
			
		//Load Dialog
		$('#dialog').dialog({
		
		
			width: 500,height:650,modal: true,
			
			buttons: {
			"Close": function() { $(this).dialog("close"); },
			"cancel": function() {
					cancelBooking();
			},
			"Save": function() {
			saveData();
			}
			} ,
		
		
		
		});
	}
	
	function cancelBooking(){
		
		if (confirm("Are you sure you want to cancel")) {
  
	 booking_id = $("#booking_id").val();
	 
	 $.ajax({
        type: 'POST',
        url: 'index.php?task=booking_cancel',
         data: { booking_id:booking_id},
        cache: false,
        success: function(result) {
			
			$("#dialogConfirm").dialog("close");
			$("#dialog").dialog("close");
			$('#calendar').fullCalendar( 'removeEvents' , booking_id );
            //how can I copy the results to be able to return them?
        }
		 });
	   

	  
  }
	}