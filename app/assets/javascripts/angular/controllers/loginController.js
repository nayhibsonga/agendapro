(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('LoginController', LoginController);

    LoginController.$inject = ['$scope','$rootScope', 'AuthenticationFactory'];

    function LoginController($scope, $rootScope, Auth) {
        var vm = this;
        vm.title = 'LoginController';
        vm.option = 'login';
        vm.toggleAccount = toggleAccount;
        vm.userInfo = {
            name: '',
            email: '',
            password: '',
            type: vm.option,
            remember_me: false,
            deals: false
        };
        vm.submit = submit;

        $scope.$watch(function(){
          return $scope.tc.option;
        },function(){
          vm.option = $scope.tc.option;
        });

        function toggleAccount(){
          vm.option = (vm.option === 'login' ? 'register' : 'login');
        }

        function submit(){

        }
    }
})();
