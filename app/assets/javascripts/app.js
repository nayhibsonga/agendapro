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
        'ui.sortable'
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
      .when($namespace + '/header', {
          templateUrl: $namespace + '/header'
      })
      .when($namespace + '/footer', {
          templateUrl: $namespace + '/footer'
      })
      .when($namespace + '/buscar', {
          templateUrl: $namespace + '/results',
          controller: 'ResultsController',
          controllerAs: 'rc',
          cache: false
      })
      .when($namespace + '/ver/:company', {
          templateUrl: $namespace + '/show',
          controller: 'ResultsController',
          controllerAs: 'rc',
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
  }

  function globalVariables($rootScope, Translator) {
    $rootScope.baseUrl = '/hora_chic';
    $rootScope.country = 'cl';
    $rootScope.lang = Translator.init($rootScope.country);
  }
})();
