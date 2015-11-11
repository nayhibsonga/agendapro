(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ResultsController', ResultsController);

    ResultsController.$inject = ['$scope','$rootScope', '$cookies', '$routeParams', 'AgendaProApi'];

    function ResultsController($scope, $rootScope, $cookies, $routeParams, AgendaProApi) {
        var vm = this;
        vm.title = 'Results';
        vm.address = $cookies.get('formatted_address');
        vm.showUrl = $rootScope.baseUrl + "/show/"
        vm.searchResults = [];
        vm.error = '';

        checkLocation();


        function checkLocation(){
            var criteria = $routeParams;
            if ( !criteria.latitude || !criteria.longitude ) {
                angular.merge( criteria, $rootScope.defaultLatLng );
            }

            getResults(criteria);
        }


        function getResults( criteria ) {
            AgendaProApi.search(criteria).then(function(data){
                if( angular.isObject(data) && data.length == 0 ) {
                    vm.error = "No se encontraron coincidencias, Intente Nuevamente.";
                } else {
                    vm.error = "";
                    vm.searchResults = data;
                }
            });
        }
    }
})();
