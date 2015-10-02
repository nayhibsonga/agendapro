(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('LinksController', LinksController);

    function LinksController() {
        var vm = this;
        var baseUrl = "/hora_chic/";

        vm.title = 'LinksController';
        vm.services = [
            { name: 'peluquerias', url: baseUrl + 'buscar?service=peluquerias'},
            { name: 'maquillaje', url: baseUrl + 'maquillaje'},
            { name: 'estetica', url: baseUrl + 'estetica'},
            { name: 'spa', url: baseUrl + 'spa'},
            { name: 'tratamientos', url: baseUrl + 'tratamientos'},
            { name: 'manos_y_pies', url: baseUrl + 'manos-y-pies'},
            { name: 'deals', url: baseUrl + 'promociones'},
            { name: 'blog', url: baseUrl + 'blog'},
        ];

        vm.social = [
            { name: 'facebook', url: 'https://www.facebook.com/agendapro' },
            { name: 'twitter', url: 'https://twitter.com/AgendaPro_CL' },
            { name: 'instagram', url: 'https://instagram.com/agendapro/' }
        ];
    }
})();
