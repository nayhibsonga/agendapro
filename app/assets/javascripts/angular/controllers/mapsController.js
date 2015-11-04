(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('MapsController', MapsController);

    MapsController.$inject = ['$cookies', '$scope'];

    function MapsController($cookies, $scope) {
        var vm = this,
            lat = $cookies.get('lat'),
            lng = $cookies.get('lng');

        vm.title = 'Maps';
        vm.map = {center: {latitude: lat, longitude: lng }, zoom: 14 };
        vm.results = [];
        vm.markers = [];
        vm.markerClick = markerClick;

        $scope.$watch(function(){
            return $scope.rc.searchResults;
        }, function(){
            vm.results = $scope.rc.searchResults || [];
            vm.markers = getMarkers();
        });

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
