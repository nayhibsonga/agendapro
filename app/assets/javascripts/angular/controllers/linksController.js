(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('LinksController', LinksController);

    LinksController.$inject = ['$rootScope'];

    function LinksController($rootScope) {
        var vm = this;
        var baseUrl = $rootScope.baseUrl;
        var searchUrl = baseUrl + "/browse?search_text=";

        vm.title = 'LinksController';
        vm.services = [
            { name: 'peluquerias', url: searchUrl + 'peluquerias'},
            { name: 'maquillaje', url: searchUrl + 'maquillaje'},
            { name: 'estetica', url: searchUrl + 'estetica'},
            { name: 'spa', url: searchUrl + 'spa'},
            { name: 'tratamientos', url: searchUrl + 'tratamientos'},
            { name: 'manos_y_pies', url: searchUrl + 'manos-y-pies'},
            { name: 'deals', url: baseUrl + '/promociones'},
            { name: 'blog', url: baseUrl + '/blog'},
        ];

        vm.social = [
            { name: 'facebook', url: 'https://www.facebook.com/agendapro' },
            { name: 'twitter', url: 'https://twitter.com/AgendaPro_CL' },
            { name: 'instagram', url: 'https://instagram.com/agendapro/' }
        ];
    }
})();
