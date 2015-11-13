(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('DealsController', DealsController);

    DealsController.$inject = ['AgendaProApi'];

    function DealsController(AgendaProApi) {
        var vm = this;
        vm.deals = [];
        vm.showTitle = true;
        vm.fetchDeals = fetchDeals;
        vm.fetchPreview = fetchPreview;

        function fetchDeals() {
            console.log("ALL");
            // Resolve Deals
            AgendaProApi.deals().then(function(data){
              vm.deals = data;
            });
        }

        function fetchPreview() {
            console.log("PREVIEW");
            // Resolve Deals Preview
            AgendaProApi.deals_preview().then(function(data){
              vm.deals = data;
            });
        }

    }
})();
