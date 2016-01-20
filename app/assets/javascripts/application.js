//= require bootstrap
//= require ga
//= require sweetalert.min
//= require ckeditor/init

//por defecto:
//= require jquery_ujs
// require turbolinks
var alertDismiss;
$(function () {
	alertDismiss = setTimeout(function () {
		$('.alert').alert('close');
	}, 3000);
});

/*
* Auxiliary function for validation removal (when going back a step).
*/

function clearValidations(element)
{
  $(element).closest(".payment-form-div").removeClass("has-success")
  $(element).closest(".payment-form-div").removeClass("has-error")

  $(element).closest(".payment-form-div").find(".form-control").removeClass("valid")

  $(element).closest(".payment-form-div").find(".form-control-feedback").removeClass("fa")

  $(element).closest(".payment-form-div").find(".form-control-feedback").removeClass("fa-check")
  $(element).closest(".payment-form-div").find(".form-control-feedback").removeClass("fa-times")

  $(element).closest(".payment-form-div").find(".help-block").empty();

  $(element).closest(".form-group").removeClass("has-success")
  $(element).closest(".form-group").removeClass("has-error")

  $(element).closest(".form-group").find(".form-control").removeClass("valid")

  $(element).closest(".form-group").find(".form-control-feedback").removeClass("fa")

  $(element).closest(".form-group").find(".form-control-feedback").removeClass("fa-check")
  $(element).closest(".form-group").find(".form-control-feedback").removeClass("fa-times")

  $(element).closest(".form-group").find(".help-block").empty();

}
