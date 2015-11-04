//= require ./angular/libs/javascripts/jquery-1.11.3.min
//= require ./angular/libs/javascripts/angular.min
//= require ./angular/libs/javascripts/angular-resource.min
//= require ./angular/libs/javascripts/angular-route.min
//= require ./angular/libs/javascripts/angular-cookies.min
//= require ./angular/libs/javascripts/angular-animate.min
//= require ./angular/libs/javascripts/google-maps/lodash.min
//= require ./angular/libs/javascripts/google-maps/index
//= require ./angular/libs/javascripts/google-maps/angular-google-maps.min
//= require ./angular/libs/javascripts/google-maps/ngAutocomplete
//= require ./angular/libs/javascripts/jquery-ui.min
//= require app
//= require_tree ./angular

// Re organize Tmpls on complete App separation

var HoraChic = (function() {
  function init() {
    $('.toggle-menu').jPushMenu();
  }

  return {init: init}
})();
