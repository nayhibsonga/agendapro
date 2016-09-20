$(function() {
	$('#new_user').validate({
		errorPlacement: function(error, element) {
			if (element.attr("id") == 'terms') {
				error.appendTo(element.parent().next());
			}
			else if (element.attr('id') == 'user_company_attributes_web_address') {
				error.appendTo(element.parent().parent().next().children('.help-block'));
			}
			else {
				error.appendTo(element.next());
			}
		},
		rules: {
			'user[full_name]': {
				required: true
			},
			'user[email]': {
				required: true,
				email: true,
				remote: '/check_user'
			},
			'user[password]': {
				required: true,
				rangelength: [8, 128]
			},
			'user[password_confirmation]': {
				required: true,
				rangelength: [8, 128],
				equalTo: $('input[name="user[password]"]:last')
			},
			'user[company_attributes][name]': {
				required: true,
				minlength: 3,
				maxlength: 200
			},
			'user[company_attributes][web_address]': {
				required: true,
				minlength: 3,
				maxlength: 200,
				remote: {
					url: "/check_company",
					type: "get",
					data: {
					  web_address: function() {
					    return $( "#user_company_attributes_web_address" ).val();
					  },
					  country_id: function() {
					    return $( "#user_company_attributes_country_id" ).val();
					  }
					}
				}
			},
			terms: {
				required: true
			}
		},
		messages: {
			'user[email]': {
				remote: 'El e-mail ya existe, puedes crear tu compañia <a href="/add_company">aquí</a>.'
			},
			'user[company_attributes][web_address]': {
				remote: 'La dirección web ya existe'
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
			var tmp = $('#user_company_attributes_web_address').val();
			tmp = tmp.toLowerCase();
			tmp = tmp.replace(/[^a-z0-9]/gi,'');
			$('#user_company_attributes_web_address').val(tmp);
			form.submit();
		}
	});

	$('#user_company_attributes_country_id').change(function() {
		$('#user_company_attributes_web_address').valid();
	});
});