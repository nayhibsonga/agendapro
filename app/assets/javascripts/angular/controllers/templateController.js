(function (){
    'use strict'

    angular
        .module('HoraChic')
        .controller('TemplateController', TemplateController);

    TemplateController.$inject = ['$rootScope', '$scope', 'AuthenticationFactory', '$location'];

    function TemplateController($rootScope, $scope, Auth, $location) {
        var vm = this;
        var baseUrl = $rootScope.baseUrl;
        vm.lang = $rootScope.lang;
        vm.option = 'login'; //Controls Login/Register modal
        vm.signIn = signIn;
        vm.signUp = signUp;
        vm.user = {};
        vm.loggedIn = false;
        vm.logout = logout;
        vm.goHome = goHome;

        // Templates are used when no Redirect to new
        // page is required, this will store every
        // reference to views 'included', as partials.
        // Use routing/templates render for redirections
        vm.templates = {
            header: baseUrl + '/header',
            footer: baseUrl + '/footer',
            deals: {
                list: baseUrl + '/deals/_list'
            },
            search: baseUrl + '/search',
            map: baseUrl + '/map',
            login: baseUrl + '/login',
            show: {
                categories: baseUrl + '/show/_categories',
                comments: baseUrl + '/show/_comments',
                schedule: baseUrl + '/show/_schedule',
                summary: baseUrl + '/show/_summary',
                step1: baseUrl + '/show/_step1',
                step2: baseUrl + '/show/_step2',
                success: baseUrl + '/show/success'
            }
        };
        // To render a new element in the main content
        // section, just change the route to the template
        // In its scope.
        vm.template = vm.templates.landing;

        Auth.getUser().then(function(response) {
            // This could return null object
            if ( response.id ) {
                vm.user = response;
            } else {
                vm.user = {};
            }
        });

        $scope.$watch(function() {
            return vm.user;
        }, function() {
            vm.loggedIn = isLogged();
            if ( vm.loggedIn ) { hideModal(); }
        });

        function signIn() {
            vm.option = 'login';
            showModal();
        }

        function signUp() {
            vm.option = 'register';
            showModal();
        }

        function logout() {
            vm.user = Auth.logout();
        }

        function showModal() {
            $('#login').modal({
                backdrop: 'static'
            });
        }

        function hideModal() {
            $('#login').modal('hide');
        }

        function isLogged() {
            var logged = false;

            if( vm.user ) {
                logged = Object.keys(vm.user).length > 0;
            }

            return logged;
        }

        function goHome() {
            $location.path('/');
        }

    }
})();
