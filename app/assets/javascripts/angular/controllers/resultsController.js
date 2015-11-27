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

        $scope.$watch(function(){
            return $rootScope;
        },function(n, o){
            console.log("ROOTSCOPE MODIFIED: ", o, n);
        });

        function checkLocation(){
            var criteria = $routeParams;

            console.log("RootScope: ", $rootScope);

            if ( !criteria.latitude || !criteria.longitude ) {
                console.log($rootScope.defaultLatLng);
                angular.merge( criteria, $rootScope.defaultLatLng );
                console.log($rootScope.defaultLatLng);
            }

            getResults(criteria);
        }

        function getResults( criteria ) {
            console.log(criteria);
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
