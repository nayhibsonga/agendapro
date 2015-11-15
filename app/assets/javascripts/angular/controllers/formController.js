(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('FormController', FormController);

    FormController.$inject = ['$scope'];

    function FormController($scope) {
        var vm = this;
        vm.title = 'FormController';
        vm.ctrlSource = '';
        vm.user = {};

        function setUserInfo(ctrl) {
            console.log(vm.title, ">> ADD LOGGED USER LOGIC HERE !!!");
            vm.ctrlSource = ctrl;
            var userExist = (Object.keys($scope[vm.ctrlSource].user).length > 0);

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

            $scope.$watch(function(){
              return vm.user;
            }, function(){
              $scope[vm.ctrlSource].user = vm.user;
            });
        }

    }
})();
