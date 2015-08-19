var validator_product;
var validator_product_category;
$(function() {
	validator_product = $('#new_product, [id^="edit_product_"]').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'product[name]': {
				required: true,
				minlength: 3
			},
			'product[product_category_id]': {
				required: true
			},
			'product[price]': {
				required: true
			}
			// ,
			// 'product[location_ids_quantity][]': {
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
				saveProduct('PATCH','/'+$("#id_data").data('id'));
			}
			else {
				saveProduct('POST','');
			}
		}
	});

	validator_product_category = $('#new_product_category').validate({
		errorPlacement: function(error, element) {
			error.appendTo(element.next());
		},
		rules: {
			'product_category[name]': {
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
			saveCategory('POST','');
		}
	});
});