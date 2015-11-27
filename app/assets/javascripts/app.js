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
        'ngAutocomplete',
        'satellizer'
      ])
    .config(config)
    .run(globalVariables);

  config.$inject = ['$routeProvider', 'uiGmapGoogleMapApiProvider','$locationProvider', '$authProvider'];
  globalVariables.$inject = ['$rootScope', 'Translator'];

  function config($routeProvider, GoogleMapApiProvider, $locationProvider, $authProvider) {
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
          templateUrl: $namespace + '/_results',
          controller: 'ResultsController',
          controllerAs: 'rc',
          cache: false
      })
      .when($namespace + '/show/:id', {
          templateUrl: $namespace + '/show/indexx',
          controller: 'ShowController',
          controllerAs: 'sc',
          cache: false
      })
      .when($namespace + '/booking/success/:id/:access_code', {
          templateUrl: $namespace + '/booking/success',
          controller: 'BookingController',
          controllerAs: 'bc',
          cache: false
      })
      .when($namespace + '/deals', {
          templateUrl: $namespace + '/deals/indexx',
          cache: false
      })
      .when($namespace + '/deals/:id', {
          templateUrl: $namespace + '/deals/_show',
          controller: 'DealsController',
          controllerAs: 'dc',
          cache: false
      })
      .when($namespace + '/company', {
          templateUrl: $namespace + '/_company',
          controller: 'CompanyController',
          controllerAs: 'cc',
          cache: false
      })
      .otherwise({
          redirectTo: $namespace + '/'
      });

    GoogleMapApiProvider.configure({
      key: 'AIzaSyDo3-SMZv9iaJs-cCs59Vz-B89jKQb_rkw',
      v: '3.20', //defaults to latest 3.X anyhow
      libraries: 'weather,geometry,visualization'
    });

    $authProvider.baseUrl = $namespace;

    $authProvider.facebook({
      clientId: '773355642790397',
      redirectUri: window.location.origin + $namespace + '/'
    });

    $authProvider.google({
      clientId: 'Google Client ID'
    });
  }

  function globalVariables($rootScope, Translator) {
    $rootScope.baseUrl = '/hora_chic';
    $rootScope.country = 'cl';
    $rootScope.lang = Translator.init($rootScope.country);
    $rootScope.defaultLatLng = { latitude: -33.448890, longitude: -70.669265 };
  }

})();
