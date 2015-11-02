(function() {
    'use strict';

    angular
        .module('HoraChic')
        .factory('AuthenticationFactory', AuthenticationFactory);

    AuthenticationFactory.$inject = ['$rootScope', '$cacheFactory'];

    function AuthenticationFactory($rootScope, $cacheFactory) {
        var service = {
            register: register
        };
        return service;

        var header = "X-Auth-Token",
            authUrl = "http://www.bambucalendar.cl:83/api_views/marketplace/v1/users/";
            $cache = $cacheFactory('apiKey');
            apiKey = '';

        var AuthCalls = { get: get, post: post, put: put };
        ////////////////

        function register(user) {
            var url = "/registration";
            user.url = url;
            AuthCalls.post(user);
        }

        function get(url) {
            var url = authUrl + url;

            return $http.get(url).then(
                handleResponse,
                AuthApiError
            );
        }

        function post(request) {
            var url = authUrl + request.url;

            if( request.apiKey ) {
                $http.defaults.headers.common[header] = request.apiKey;
            }

            return $http.post(url, request).then(
                handleResponse,
                AuthApiError
            );
        }

        function handleResponse(response) {
            var data = response.data,
                status = data.status === undefined ? data.status : data.status.charAt(0);

            if(status === "5" || status === "4") {
                new AuthApiError;
            } else {
                return response.data;
            }
        }

        function AuthApiError(response){
            var response = response || {};
            this.error = response.error || 'Unidentified Error';
        }

    }
})();
