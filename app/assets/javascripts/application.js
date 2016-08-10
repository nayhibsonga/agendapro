//= require bootstrap
//= require ga
//= require sweetalert.min
//= require ckeditor/init
//= require toastr.min
//= require surveys
// require toastr.js.map

//por defecto:
//= require jquery_ujs
// require turbolinks
// var alertDismiss;
// $(function () {
// 	alertDismiss = setTimeout(function () {
// 		$('.alert').alert('close');
// 	}, 3000);
// });

toastr.options = {
  "closeButton": true,
  "debug": false,
  "newestOnTop": true,
  "progressBar": false,
  "positionClass": "toast-top-full-width",
  "preventDuplicates": false,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "3000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

function triggerAlert(message)
{
  toastr["warning"](message);
}

function triggerSuccess(message)
{
  toastr["success"](message);
}

function triggerInfo(message)
{
  toastr["info"](message);
}

function triggerError(message)
{
  toastr["error"](message);
}

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
