//= require ./angular/libs/javascripts/jquery-1.11.3.min
//= require ./angular/libs/javascripts/angular.min
//= require ./angular/libs/javascripts/angular-resource.min
//= require ./angular/libs/javascripts/angular-route.min
//= require app
//= require_tree ./angular

// Re organize Tmpls on complete App separation

var HoraChic = (function() {
  function init() {
    $('.toggle-menu').jPushMenu();
  }

  return {init: init}
})();
