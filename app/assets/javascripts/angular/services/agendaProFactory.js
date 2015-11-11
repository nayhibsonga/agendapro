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
            show: show,
            weeklyHours: weeklyHours,
            defaultLocation: defaultLocation
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

        function weeklyHours(date, local, services) {
            // i.e ?date=yyyy-mm-dd&local=1&serviceStaff=[{"service":serviceID,"provider": providerID}]
            var params = {},
                servicesStaff = [];

            if( angular.isDate(date) ) {
                var fmtDate = "";
                fmtDate += date.getFullYear() + "-";
                fmtDate += date.getMonth() + 1 + "-";
                fmtDate += ("0" + date.getDate()).slice(-2);
                date = fmtDate;
            }

            params.date =  date;
            params.local = local;

            for (var i = 0; i < services.length; i++) {
                servicesStaff.push({
                    'service': services[i].id.toString(),
                    'provider': (services[i].providerAssigned || 0).toString()
                });
            };

            params.serviceStaff = JSON.stringify(servicesStaff);

            var url = '/service_providers/available_hours?'.concat($.param(params));
            //var url = '/service_providers/available_hours?date=2015-11-26&local=1&serviceStaff=[{"service":"1","provider":"1"}]';

            return ApiCalls.get(url);
        }

        function defaultLocation() {
            var url = '/default_location';
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
