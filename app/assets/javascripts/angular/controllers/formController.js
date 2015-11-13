(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('FormController', FormController);

    FormController.$inject = ['$scope'];

    function FormController($scope) {
        var vm = this;
        vm.title = 'FormController';
        vm.user = {};

        setUserInfo();

        function setUserInfo() {
            console.log(vm.title, ">> ADD LOGGED USER LOGIC HERE !!!");
            var userExist = (Object.keys($scope.sc.user).length > 0);

            if( userExist ) {
                vm.user = $scope.sc.user;
            } else {
                 vm.user = newUser();
            }

            function newUser() {
                var user = {};

                user.name = '';
                user.email = '';
                user.phone = '';
                user.notes = '';
                user.mailing_option = false;

                return user;
            }
        }

        $scope.$watch(function(){
          return vm.user;
        }, function(){
          $scope.sc.user = vm.user;
        });

    }
})();
