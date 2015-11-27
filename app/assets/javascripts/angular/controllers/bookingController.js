(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('BookingController', BookingController);

    BookingController.$inject = ['$scope', '$rootScope', 'AgendaProApi', '$location'];

    function BookingController($scope, $rootScope, AgendaProApi, $location) {
        var vm = this;
        vm.title = 'BookingController';
    }

})();
