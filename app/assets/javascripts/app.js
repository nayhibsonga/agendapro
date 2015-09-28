(function() {
  'use strict'

  angular
    .module('HoraChic', [
        'ngResource',
        'ngRoute',
        'uiGmapgoogle-maps',
        'ngCookies'
      ])
    .config(config)
    .run(globalVariables);

  config.$inject = ['$routeProvider', 'uiGmapGoogleMapApiProvider'];

  function config($routeProvider, GoogleMapApiProvider) {
    var $namespace = '/hora_chic';
    $routeProvider
      .when('/', {
          templateUrl: $namespace,
          controller: 'TemplateController'
      })
      .when($namespace + '/landing', {
          templateUrl: $namespace + '/landing',
          controller: 'TemplateController'
      })
      .when($namespace + '/header', {
          templateUrl: $namespace + '/header',
          controller: 'TemplateController'
      })
      .when($namespace + '/footer', {
          templateUrl: $namespace + '/footer',
          controller: 'TemplateController'
      })
      .otherwise({
          redirectTo: '/'
      });

    GoogleMapApiProvider.configure({
      key: 'AIzaSyDeFsCNzRfUK7Yretd1EBgGL73O1PJOEZM',
      v: '3.20', //defaults to latest 3.X anyhow
      libraries: 'weather,geometry,visualization'
    });
  }

  function globalVariables($rootScope) {
    $rootScope.country = 'cl';
  }
})();
