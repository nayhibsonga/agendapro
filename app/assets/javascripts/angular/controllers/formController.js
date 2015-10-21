(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('FormController', FormController);

    FormController.$inject = ['$scope'];

    function FormController($scope) {
        var vm = this;
        vm.title = 'FormController';
        vm.user = {
          name: '',
          email: '',
          phone: '',
          comment: '',
          promotions: false,
          reservation: {}
        }

        activate();

        ////////////////

        function activate() {
        }
    }
})();
