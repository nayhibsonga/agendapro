function cancelBooking(){
		if (confirm("Are you sure you want to cancel")) {
	  
		 booking_id = $("#booking_id").val();
		 
		 $.ajax({
			type: 'POST',
			url: 'index.php?task=booking_cancel',
			 data: { booking_id:booking_id},
			cache: false,
			success: function(result) {
				
				$('#calendar').fullCalendar('removeEvents',booking_id);
				$("#dialog").dialog("close");
			}
			 });
		   
	
		  
	  } 
  }
  
  function saveBooking(){
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
	   
	   if (!validateEmail(email)) {
        
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
		
			$('#calendar').fullCalendar('refetchEvents');
			
			$("#dialog").dialog("close");
            
        }
		 });
			}else{
				  alert('Only one service is required when select group service');
            		return;
			}
        });
		   
	   
  
  }