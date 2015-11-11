(function() {
  'use strict'

  angular
    .module('HoraChic', [
        'ngResource',
        'ngRoute',
        'uiGmapgoogle-maps',
        'ngCookies',
        'ngAnimate',
        'ui.bootstrap',
        'ui.sortable',
        'ngAutocomplete'
      ])
    .config(config)
    .run(globalVariables);

  config.$inject = ['$routeProvider', 'uiGmapGoogleMapApiProvider','$locationProvider'];

  function config($routeProvider, GoogleMapApiProvider, $locationProvider) {
    var $namespace = '/hora_chic';

    $locationProvider.html5Mode(true);

    $routeProvider
      .when($namespace + '/', {
          templateUrl: $namespace + '/landing',
          controller: 'LandingController',
          controllerAs: 'lc'
      })
      .when($namespace + '/footer', {
          templateUrl: $namespace + '/footer'
      })
      .when($namespace + '/browse', {
          templateUrl: $namespace + '/results',
          controller: 'ResultsController',
          controllerAs: 'rc',
          cache: false
      })
      .when($namespace + '/show/:id', {
          templateUrl: $namespace + '/show/index',
          controller: 'ShowController',
          controllerAs: 'sc',
          cache: false
      })
      .otherwise({
          redirectTo: $namespace + '/'
      });

    GoogleMapApiProvider.configure({
      key: 'AIzaSyDeFsCNzRfUK7Yretd1EBgGL73O1PJOEZM',
      v: '3.20', //defaults to latest 3.X anyhow
      libraries: 'weather,geometry,visualization'
    });
  }

  function globalVariables($rootScope, Translator) {
    $rootScope.baseUrl = '/hora_chic';
    $rootScope.country = 'cl';
    $rootScope.lang = Translator.init($rootScope.country);
    $rootScope.defaultLatLng = { latitude: -33.448890, longitude: -70.669265 };
  }

})();
