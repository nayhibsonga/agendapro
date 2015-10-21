(function (){
    'use strict'

    angular
        .module('HoraChic')
        .controller('TemplateController', TemplateController);

    TemplateController.$inject = ['$rootScope'];

    function TemplateController($rootScope) {
        var vm = this;
        var baseUrl = $rootScope.baseUrl;
        vm.lang = $rootScope.lang;
        vm.templates = {
            landing: baseUrl + '/landing',
            deals: baseUrl + '/deals',
            search: baseUrl + '/search',
            map: baseUrl + '/map',
            schedule: baseUrl + '/schedule',
            comments: baseUrl + '/comments'
        };
        // To render a new element in the main content
        // section, just change the route to the template
        // In its scope.
        vm.template = vm.templates.landing;
    }
})();
