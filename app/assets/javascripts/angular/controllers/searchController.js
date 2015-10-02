(function () {
    'use strict'

    angular
        .module('HoraChic')
        .controller('SearchController', SearchController);

    SearchController.$inject = ['uiGmapGoogleMapApi', '$cookies', '$rootScope'];

    function SearchController(GoogleMapApi, $cookies, $rootScope) {
        // vm = ViewModel
        var vm = this;
        vm.lang = $rootScope.lang;
        var geoErrors = vm.lang.error.geolocation;
        vm.addressName = $cookies.get('formatted_address') || '';
        vm.getLocation = getLocation;
        vm.showPosition = showPosition;
        vm.showError = showError;

        function getLocation() {
            if (navigator.geolocation) {
                navigator
                    .geolocation
                    .getCurrentPosition(vm.showPosition, vm.showError);
            }
            else {
                vm.error = geoErrors.navigator;
            }
        }

        function showPosition(position) {
            var lat = position.coords.latitude,
                lng = position.coords.longitude;

            $cookies.put('lat', lat);
            $cookies.put('lng', lng);

            GoogleMapApi.then(function(maps) {
                var latlng = new maps.LatLng(lat, lng);
                var geocoder = new maps.Geocoder();
                geocoder.geocode({'latLng': latlng}, function(results, status) {
                    vm.addressName = results[0].formatted_address;
                    $cookies.put('formatted_address', vm.addressName);
                    vm.$apply();
                });
            });
        }

        function showError(error) {
            switch (error.code) {
            case error.PERMISSION_DENIED:
                vm.error = geoErrors.permission_denied;
                break;
            case error.POSITION_UNAVAILABLE:
                vm.error = geoErrors.position_unavailable;
                break;
            case error.TIMEOUT:
                vm.error = geoErrors.timeout;
                break;
            case error.UNKNOWN_ERROR:
                vm.error = geoErrors.unknown_error;
                break;
            }
        }

    }

})();
