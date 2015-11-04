(function() {
    'use strict';

    angular
        .module('HoraChic')
        .factory('AgendaProApi', AgendaProApi);

    AgendaProApi.$inject = ['$http', '$rootScope'];

    function AgendaProApi($http, $rootScope) {
        var baseUrl = 'http://www.bambucalendar.cl:83/api_views/marketplace/v1';
        var countryId = getCountryId($rootScope.country);

        // AgendaProApi public methods

        var service = {
            deals_preview: deals_preview,
            search: search,
            show: show
        }

        var ApiCalls = { get: get, post: post }

        return service;

        // Private methods

        function deals_preview(country) {
            var url = '/promotions/index/preview?country_id='.concat(countryId);
            return ApiCalls.get(url);
        }

        function search(params) {
            var url = '/locations?'.concat($.param(params));
            return ApiCalls.get(url);
        }

        function show(id) {
            var url = '/locations/'.concat(id);
            return ApiCalls.get(url);
        }

        // Requests Method

        function get(url) {
            return $http.get(baseUrl + url).then(function(response) {
                var data = response.data,
                    status = data.status === undefined ? data.status : data.status.charAt(0);
                if(status === "5" || status === "4") {
                    AgendaProApiError
                } else {
                    return response.data;
                }

            }, AgendaProApiError);
        }

        function post(url) {
            return true;
        }

        // Custom functions

        function AgendaProApiError(response) {
            // TODO NOTIFIER
            var error = { 'error': response };
            return null;
        }

        function getCountryId(country) {
            switch(country) {
                // Add Country Id's
                default: return 1;
            }
        }

    }
})();
