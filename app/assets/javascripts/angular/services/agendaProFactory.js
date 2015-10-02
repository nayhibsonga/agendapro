(function() {
    'use strict';

    angular
        .module('HoraChic')
        .factory('AgendaProApi', AgendaProApi);

    AgendaProApi.$inject = ['$http', '$rootScope'];

    function AgendaProApi($http, $rootScope) {
        var baseUrl = '/api_views/marketplace/v1';
        var countryId = getCountryId($rootScope.country);

        // AgendaProApi public methods

        var service = {
            deals_preview: deals_preview
        }

        var ApiCalls = { get: get, post: post }

        return service;

        // Private methods

        function deals_preview(country) {
            var url = '/promotions/index/preview?country_id='.concat(countryId);
            return ApiCalls.get(url);
        }

        // Requests Method

        function get(url) {
            return $http.get(baseUrl + url).then(function(response) {
                return response.data;
            }, AgendaProApiError);
        }

        function post(url) {
            return true;
        }

        // Custom functions

        function AgendaProApiError(response) {
            return { 'error': response };
        }

        function getCountryId(country) {
            switch(country) {
                // Add Country Id's
                default: return 1;
            }
        }

    }
})();
