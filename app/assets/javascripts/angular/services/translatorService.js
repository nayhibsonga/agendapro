(function() {
  'use strict';

  angular
    .module('HoraChic')
    .service('Translator', Translator);

  Translator.$inject = ['Language'];

  function Translator(Language) {
    this.init = init;

    function init(country) {
      var locale = Language.locale(country);
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
            typed: ["SPA", "Masajes", "Manicure", "Pedicure", "Maquillaje", "Bronceados", "Peluquerías", "Corte de Pelo", "Centros de Estética", "Medicina Alternativa", "Tratamientos Faciales", "Tratamientos Corporales"],
            deals: {
              title: "Promociones Destacadas",
              sub_title: "¡Promociones destacadas de este mes!"
            }
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
          },
          account: {
            sign_up: 'Registrate',
            sign_in: 'Ingresar',
            login: {
              title: 'Inicia Sesión',
              optional: 'Ingresa con tus cuentas de Facebook o Google',
              hora_chic: 'O ingresa con tu cuenta',
              check: 'Recordarme',
              retrieve_passwd: '¿Olvidaste tu contraseña?',
              account_question: '¿Aún no tienes cuenta?',
              toggle_button: 'Registrate',
              go: 'Ingresa'
            },
            register: {
              title: 'Regístrate',
              optional: 'Regístrate con tus cuentas de Facebook o Google',
              hora_chic: 'O crea tu cuenta',
              check: '¿Quieres recibir nuestras promociones a tu email?',
              retrieve_passwd: '',
              account_question: '¿Ya tienes cuenta?',
              toggle_button: 'Ingresar',
              go: 'Regístrate'
            },
            form: {
              name: 'Nombre',
              email: 'Email',
              password: 'Contraseña'
            }
          },
          step1: {
            legend: {
              deals: 'Día con promociones disponibles'
            },
            section: {
              morning_hours: 'Mañana',
              afternoon_hours: 'Tarde',
              night_hours: 'Noche',
              empty_hours: '*No hay horarios disponibles...'
            },
            detail: {
              appointment: 'Detalle de Reserva'
            }
          },
          booking: {
            success: ', tu reserva fue recibida exitosamente',
            service: 'Servicio',
            where: '¿Dónde?',
            day: 'Día y Hora',
            name: 'Nombre',
            email: 'Email',
            phone: 'Teléfono'
          }
        }
      }

      return translations[locale];
    }


  }
})();
