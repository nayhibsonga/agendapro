'use strict'
// FIXME
angular.module('HoraChic')
  .factory('Translations', function translationFactory(country){
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

    var Translations = (function() {
      function Translations(locale) {
        var lang = Language(locale);
        return {
          'es-CL': {
            contact: 'contacto@agendapro.cl',
            writeUs: '¿Dudas? escríbenos a',
            login: 'Inicia Sesión',
            register: 'Regístrate',
            addCompany: 'Agrega tu Empresa'
          }
        }[lang];
      }

      return Translations;

    })();

    return Translations(country);
  });