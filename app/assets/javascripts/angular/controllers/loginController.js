(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('LoginController', LoginController);

    LoginController.$inject = ['$scope','$rootScope', 'AuthenticationFactory'];

    function LoginController($scope, $rootScope, Auth) {
        var vm = this;
        vm.title = 'LoginController';
        vm.option = $scope.tc.option;
        vm.toggleAccount = toggleAccount;
        vm.userInfo = newUser();
        vm.newUser = newUser;
        vm.submit = submit;
        vm.error = "";

        bindModalCleanUp();

        $scope.$watch(function() {
            return $scope.tc.option;
        },function(){
            vm.option = $scope.tc.option;
        });

        function toggleAccount() {
            resetForm();
            vm.option = (vm.option === 'login' ? 'register' : 'login');
        }

        function submit() {
            var result = Auth[vm.option](vm.userInfo);
            if( angular.isDefined(result) && result.data && !result.data.error ) {
                result.then( handleResponse );
            } else {
                console.log("SOME ERROR IN OBJ: ", result);
            }
        }

        function handleResponse(response) {
            if( response.error ) {
                vm.error = response.message;
            } else {
                $scope.tc.user = response;
            }
        }

        function newUser() {
            var user = {};
            user.name = '';
            user.email = '';
            user.password = '';
            user.remember_me = false;
            user.deals = false;

            vm.userInfo = user;
        }

        function resetForm() {
            vm.form.$setUntouched();
            newUser();
        }

        function bindModalCleanUp() {
            $(document).on('hide.bs.modal', '#login', function() {
                resetForm();
            }).on('show.bs.modal', '#login', function() {
                resetForm();
            });
        }
    }
})();
