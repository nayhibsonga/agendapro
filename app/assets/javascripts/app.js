'use strict'

angular.module('HoraChic', ['ngResource', 'ngRoute'])
  .config(['$routeProvider', function ($routeProvider) {
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
  }]);

var Translations = (function() {
  function Translations(locale) {
    var lang = Language(locale);
    return {
      'es-CL': {
        contact: 'contacto@agendapro.cl',
        address: 'Ana María Carrera 5210, Las Condes, Santiago',
        write_us: '¿Dudas? escríbenos a',
        login: 'Inicia Sesión',
        register: 'Regístrate',
        add_company: 'Agrega tu Empresa',
        services: {
          peluquerias: "Peluquerías",
          maquillaje: "Maquillaje",
          estetica: "Centros de Estética",
          spa: "Spa",
          tratamientos: "Tratamientos",
          manos_y_pies: "Manos y Pies",
          deals: "Promociones",
          blog: "Blog"
        },
        search: {
          find_me: 'Encuéntrame',
          find_service: 'Buscar',
          placeholder: {
            address: 'Escribe tu dirección, sector o ciudad...',
            service: 'Ejemplo: Corte de Pelo, Masajes'
          }
        }

      }
    }[lang];
  }

  return Translations;

})();

var Language = (function() {
  function Language(locale) {
    switch (locale) {
      case 'co':
        return 'es-CO';
      default:
        return 'es-CL';
    }
  }

  return Language;

})();
