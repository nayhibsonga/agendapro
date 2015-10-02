(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('MapsController', MapsController);

    MapsController.$inject = ['uiGmapGoogleMapApi', '$cookies'];

    function MapsController(GoogleMapApi, $cookies) {
        var vm = this,
            lat = $cookies.get('lat'),
            lng = $cookies.get('lng');

        vm.title = 'MapsController';
        vm.map = {center: {latitude: lat, longitude: lng }, zoom: 14 };
    }
})();
