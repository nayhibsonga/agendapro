var validator_resource;
var validator_resource_category;
$(function() {
	validator_resource = $('#new_resource, [id^="edit_resource_"]').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'resource[name]': {
				required: true,
				minlength: 3
			},
			'resource[resource_category_id]': {
				required: true
			}
			// ,
			// 'resource[location_ids_quantity][]': {
			// 	required: true,
			// 	min: 0
			// }
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
			if ($("#id_data").length > 0){
				saveResource('PATCH','/'+$("#id_data").data('id'));
			}
			else {
				saveResource('POST','');
			}
		}
	});

	validator_resource_category = $('#new_resource_category').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'resource_category[name]': {
				required: true,
				minlength: 3
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
			form.submit();
		}
	});
});