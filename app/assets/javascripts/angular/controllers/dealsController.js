(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('DealsController', DealsController);

    DealsController.$inject = ['AgendaProApi'];

    function DealsController(AgendaProApi) {
        var vm = this;
        vm.deals = [];
        // Resolve Deals Preview
        AgendaProApi.deals_preview().then(function(data){
          vm.deals = data;
        });
    }
})();
