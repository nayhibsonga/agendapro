(function() {
  'use strict';

  angular
    .module('HoraChic')
    .service('Translator', Translator);

  Translator.$inject = ['$rootScope', 'Language'];

  function Translator($rootScope, Language) {
    this.init = init;

    function init() {
      var locale = Language.locale($rootScope.country);
      // Move this to a separated .json file and
      // use factory to call it
      var translations = {
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
          },
          landing: {
            typed: ["Corte de Pelo", "Tratamientos Faciales", "SPA", "Maquillaje", "Centros de Estética", "Peluquerías", "Masajes", "Manicure", "Pedicure", "Tratamientos Corporales", "Bronceados", "Medicina Alternativa"]
          },
          error: {
            geolocation: {
              generic: 'Hubo un error en el proceso de localización.',
              navigator: 'Este explorador no permite geolocalización automática, por favor escribe tu ubicación.',
              permission_denied: 'No hay permiso, por favor asegúrate permitir la geolicalización automática en tu explorador.',
              position_unavailable: 'Posición no disponible, por favor inténtalo nuevamente o escribe tu ubicación.',
              timeout: 'La consulta tardó mucho, por favor inténtalo nuevamente o escribe tu ubicación.',
              unknown_error: 'Error desconocido, por favor inténtalo nuevamente o escribe tu ubicación.'
            }
          }
        }
      }

      return translations[locale];
    }


  }
})();
