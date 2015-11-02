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
        vm.params = "?service=" + $routeParams.service + "&local=";
        vm.searchResults = [];

        AgendaProApi.search($routeParams).then(function(data){
          vm.searchResults = data;
        });

        activate();

        ////////////////

        function activate() {
        }
    }
})();
