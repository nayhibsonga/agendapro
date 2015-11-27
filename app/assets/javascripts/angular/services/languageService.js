(function() {
  'use strict';

  angular
    .module('HoraChic')
    .service('Language', Language);

  function Language() {
    this.locale = locale;

    function locale(country) {
      switch (country) {
        case 'co':
          return 'es-CO';
        default:
          return 'es-CL';
      }
    }
  }
})();
