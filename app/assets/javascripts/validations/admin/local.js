$(function() {
	$('#new_location, [id^="edit_location_"]').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'location[company_id]': {
				required: true
			},
			'location[name]': {
				required: true,
				minlength: 3
			},
			'country': {
				required: true
			},
			'region': {
				required: true
			},
			'city': {
				required: true
			},
			'location[district_id]': {
				required: true
			},
			'location[address]': {
				required: true
			},
			'location[phone]': {
				required: true,
				rangelength: [8, 15]
			},
			'location[email]': {
				email: true
			}
		},
		highlight: function(element) {
			$(element).closest('.form-group').removeClass('has-success').addClass('has-error');
			$(element).parent().children('.form-control-feedback').removeClass('fa fa-check').addClass('fa fa-times');
		},
		success: function(element) {
			$(element).closest('.form-group').removeClass('has-error').addClass('has-success');
			$(element).parent().parent().children('.form-control-feedback').removeClass('fa fa-times').addClass('fa fa-check');
			$(element).parent().empty()
		},
		submitHandler: function(form) {
			saveLocation();
			form.submit();
		}
	});

	$('input[name="location[notification]"]').change(function (event) {
		var value = $(event.target).prop('checked')
		if (value) {
			$('input[name="location[email]"]').rules('add', {
				required: true
			});
		} else{
			$('input[name="location[email]"]').rules('remove', 'required');
			$('input[name="location[email]"]').closest('.form-group').removeClass('has-error').removeClass('has-success');
			$('input[name="location[email]"]').parent().children('.form-control-feedback').removeClass('fa fa-times').removeClass('fa fa-check');
			$('input[name="location[email]"]').next().empty()
		};
	});

});

function saveLocation() {
	  var locationJSON = locJSON();
	  var locationId = $('#id_data').data('id');
	  if ( $('#title').length > 0 ) {
	    $.ajax({
	      type: "PATCH",
	      url: ' /locations/'+ JSON.stringify(locationId) +'.json',
	      data: { location: locationJSON },
	      dataType: 'json',
	      success: function(){
	        document.location.href = '/locations/';
	      },
	      error: function(xhr){
	        var errors = $.parseJSON(xhr.responseText).errors;
	        var errorList = '';
	        var num_limit = false;
	        for(i in errors) {
	          console.log(errors[i]);
	          if (error[i] == "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
	          {
	            num_limit = true;
	          }
	        }

	        if(num_limit)
	        {
	          errorList += '<li>No se pueden agregar más locales con el plan actual, ¡mejóralo!.</li>'
	        }
	        else
	        {
	          for (i in errors) {
	            errorList += '<li>' + errors[i] + '</li>'
	          }
	        }
	        alertId.showAlert(
	          '<h3>Error</h3>' +
	          '<ul>' +
	            errorList +
	          '</ul>'
	        );
	      }
	    });
	  }
	  else {
	    var locationJSON = locJSON();
	    $.ajax({
	      type: "POST",
	      url: '/locations.json',
	      data: { "location": locationJSON },
	      dataType: 'json',
	      success: function(){
	        document.location.href = '/locations/';
	      },
	      error: function(xhr){
	        var errors = $.parseJSON(xhr.responseText).errors;
	        var errorList = '';
	        var num_limit = false;
	        for(i in errors) {
	          console.log(errors[i]);
	          if (errors[i] == "No se pueden agregar más locales con el plan actual, ¡mejóralo!.")
	          {
	            num_limit = true;
	          }
	        }

	        if(num_limit)
	        {
	          errorList += '<li>No se pueden agregar más locales con el plan actual, ¡mejóralo!.</li>'
	        }
	        else
	        {
	          for (i in errors) {
	            errorList += '<li>' + errors[i] + '</li>'
	          }
	        }
	        alertId.showAlert(
	          '<h3>Error</h3>' +
	          '<ul>' +
	            errorList +
	          '</ul>'
	        );
	      }
	    });
	  }
	}