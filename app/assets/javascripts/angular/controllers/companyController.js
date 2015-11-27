(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('CompanyController', CompanyController);

    CompanyController.$inject = ['AgendaProApi'];

    function CompanyController(AgendaProApi) {
        var vm = this;
        vm.title = 'CompanyController';
        vm.companies = [];

        AgendaProApi.companyList().then(function(response) {
          vm.companies = response;
          // activateCarousel();
        });

        function activateCarousel() {
          // $('.carousel').carousel();
        }
    }
})();
