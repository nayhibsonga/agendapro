(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ResultsController', ResultsController);

    ResultsController.$inject = ['$rootScope', '$cookies', '$routeParams'];

    function ResultsController($rootScope, $cookies, $routeParams) {
        var vm = this;
        vm.title = 'ResultsController';
        vm.address = $cookies.get('formatted_address');
        vm.showUrl = $rootScope.baseUrl + "/ver/"
        vm.params = "?service=" + $routeParams.service + "&local=";
        activate();

        ////////////////

        function activate() {
        }
    }
})();
