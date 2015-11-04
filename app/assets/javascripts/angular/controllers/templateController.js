(function (){
    'use strict'

    angular
        .module('HoraChic')
        .controller('TemplateController', TemplateController);

    TemplateController.$inject = ['$rootScope', '$scope', 'AuthenticationFactory'];

    function TemplateController($rootScope, $scope, Auth) {
        var vm = this;
        var baseUrl = $rootScope.baseUrl;
        vm.lang = $rootScope.lang;
        vm.option = 'login'; //Controls Login/Register modal
        vm.signIn = signIn;
        vm.signUp = signUp;
        vm.user = {};
        vm.loggedIn = false;
        vm.logout = logout;

        // Templates are using when no Redirect to new
        // page is required, this will store every
        // reference to views included as partials.
        // Use routing/templates render for redirections
        vm.templates = {
            header: baseUrl + '/header',
            footer: baseUrl + '/footer',
            deals: baseUrl + '/deals',
            search: baseUrl + '/search',
            map: baseUrl + '/map',
            login: baseUrl + '/login',
            show: {
                categories: baseUrl + '/show/_categories',
                comments: baseUrl + '/show/_comments',
                schedule: baseUrl + '/show/_schedule',
                summary: baseUrl + '/show/_summary'
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

    }
})();
