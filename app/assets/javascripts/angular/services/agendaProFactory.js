(function() {
    'use strict';

    angular
        .module('HoraChic')
        .factory('AgendaProApi', AgendaProApi);

    AgendaProApi.$inject = ['$http', '$rootScope'];

    function AgendaProApi($http, $rootScope) {
        var host = 'http://www.bambucalendar.cl:83',
        // var host = 'http://192.168.1.140:3000',
            baseUrl = host + '/api_views/marketplace/v1',
            countryId = getCountryId($rootScope.country);

        // AgendaProApi public methods

        var service = {
            deal: deal,
            deals: deals,
            deals_preview: deals_preview,
            search: search,
            show: show,
            weeklyHours: weeklyHours,
            defaultLocation: defaultLocation,
            sendBooking: sendBooking,
            companyList: companyList
        }

        var ApiCalls = { get: get, post: post }

        return service;

        // Private methods

        function deal(id, location) {
            var url = '/promotions/' + id + '?location_id=' + location;
            return ApiCalls.get(url);
        }

        function deals(country) {
            var url = '/promotions?country_id='.concat(countryId);
            return ApiCalls.get(url);
        }

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
                var provider = services[i].providerAssigned;
                servicesStaff.push({
                    'service': services[i].id.toString(),
                    'provider': ( provider ? provider.id : 0 ).toString()
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

        function sendBooking(data) {
            var url = '/bookings';
            return ApiCalls.post(url, data);
        }

        function companyList(country) {
            var url = '/companies_preview?country_id='.concat(countryId);
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

        function post(url, data) {
            return $http.post(baseUrl + url, data).then(function(response) {
                return response;
            }, AgendaProApiError);
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
