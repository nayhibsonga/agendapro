(function() {
    'use strict';

    angular
        .module('HoraChic')
        .factory('AuthenticationFactory', AuthenticationFactory);

    AuthenticationFactory.$inject = ['$rootScope', '$http'];

    function AuthenticationFactory($rootScope, $http) {
        var header = "X-Auth-Token",
            host = "http://localhost:3000",
            authUrl = host + "/api_views/marketplace/v1/users",
            apiKey = 'apiKey',
            AuthCalls = { get: get, post: post, put: put },
            service = { register: register, login: login, logout: logout, getUser: getUser };

        return service;

        // Public Methods

        function register(user) {
            user.url = "/registration";
            AuthCalls.post(user);
            login(user);
        }

        function login(user) {
            var loggedUser = {};
            user.url = "/session";
            user.apiKey = getApiKey();
            loggedUser = AuthCalls.post(user);

            return loggedUser;
        }

        function getUser() {
            var data = {},
                user = {};
            data.url = "/me";
            data.apiKey = getApiKey();
            user = AuthCalls.get(data);

            return user;
        }

        function logout() {
            removeApiKey();
            return {};
        }

        // Private Methods

        function get(data) {
            var url = authUrl + data.url;

            // Replace for Interceptor later
            setHeaders(data);

            return $http.get(url).then(
                handleResponse,
                AuthApiError
            );
        }

        function post(data) {
            var url = authUrl + data.url;

            // Replace for Interceptor later
            setHeaders(data);

            return $http.post(url, data).then(
                handleResponse,
                AuthApiError
            );
        }

        function put(){}

        // Handlers

        function handleResponse(response) {
            var data = response.data,
                status = data.status === undefined ? data.status : data.status.charAt(0);

            if(status === "5" || status === "4") {
                return AuthApiError;
            } else if( data.api_token ) {
                setApiKey(data.api_token);
                delete data.api_token;
            }

            return data;
        }

        function AuthApiError(response){
            var fmtResp = response;
            console.log(fmtResp);

            if ( !response || response.status !== 200 ) {
                fmtResp = {};
                fmtResp.error = true;
                fmtResp.message = response.data.error || 'Undefined Error';
                fmtResp.status = response.status || 'Undefined Status';
                fmtResp.statusText = response.statusText || 'Undefined Status Text';
            }

            return fmtResp;
        }

        function setApiKey(token) {
            if( token ) {
                removeApiKey();
                localStorage.setItem(apiKey, token);
            }
        }

        function getApiKey() {
            return localStorage.getItem(apiKey);
        }

        function removeApiKey(){
            localStorage.removeItem(apiKey);
        }

        function setHeaders(data) {
            if( data.apiKey ) {
                $http.defaults.headers.common[header] = data.apiKey;
            }
        }

    }
})();
