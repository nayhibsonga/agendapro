(function (){
    'use strict'

    angular
        .module('HoraChic')
        .controller('TemplateController', TemplateController);

    TemplateController.$inject = ['$rootScope'];

    function TemplateController($rootScope) {
        var vm = this;
        vm.lang = $rootScope.lang;
        vm.templates = {
            landing: '/hora_chic/landing',
            deals: '/hora_chic/deals',
            search: '/hora_chic/search',
            map: '/hora_chic/map'
        };
        // To render a new element in the main content
        // section, just change the route to the template
        // In its scope.
        vm.template = vm.templates.landing;
    }
})();
