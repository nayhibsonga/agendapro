(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('LandingController', LandingController);

    LandingController.$inject = ['$rootScope'];

    function LandingController($rootScope) {
        var vm = this;
        vm.title = 'LandingController';
        vm.lang = $rootScope.lang;

        activate();

        ////////////////

        function activate() {
          $("#typed").typed({
              strings: vm.lang.landing.typed,
              loop: true,
              typeSpeed: 0,
              cursorChar: "_",
              backDelay: 2000
          });
        }
    }
})();
