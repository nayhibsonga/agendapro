(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('MapsController', MapsController);

    MapsController.$inject = ['$cookies', '$scope', '$rootScope'];

    function MapsController($cookies, $scope, $rootScope) {
        var vm = this;
        vm.title = 'Maps';
        vm.map = getMap();
        vm.results = [];
        vm.markers = [];
        vm.markerClick = markerClick;

        $scope.$watch(function(){
            return $scope.rc.searchResults;
        }, function(){
            vm.results = $scope.rc.searchResults || [];
            vm.markers = getMarkers();
        });

        function getMap() {
            var lat = $cookies.get('lat'),
                lng = $cookies.get('lng'),
                map = { center: { latitude: lat, longitude: lng }, zoom: 14 };

            if( !lat || !lng ) {
                map.center = $rootScope.defaultLatLng;
                map.zoom = 10;
            }

            return map;
        }

        function getMarkers() {
            var markers = [];
            for (var i = 0; i < vm.results.length; i++) {
                var company = vm.results[i];
                markers.push({
                    id: company.id,
                    latitude: company.latitude,
                    longitude: company.longitude,
                    title: company.name
                });
            };
            return markers;
        }

        function markerClick(instance, event, obj){
            var $elem = $('#company-'.concat(obj.id));
            $('html,body').animate({
              scrollTop: $elem.offset().top
            }, 1000, function (){
                $elem.addClass('hightlight').removeClass('hightlight', 1500);
            });
        }

    }
})();
