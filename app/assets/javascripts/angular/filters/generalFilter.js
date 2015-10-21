(function() {
    'use strict';

    angular
        .module('HoraChic')
        .filter('dealsCurrency', dealsCurrency)
        .filter('startFrom', startFrom)
        .filter('clp', clp);

    function dealsCurrency() {
        return dealsCurrencyFilter;

        function dealsCurrencyFilter(price) {
            return price.replace(',','.');
        }
    }

    function startFrom() {
        return startFromFilter;

        function startFromFilter(input, start) {
            return input.slice(start);
        }
    }

    function clp() {
        return clpFilter;

        function clpFilter(price) {
            return String(price).split('.')[0].replace(',','.');
        }
    }



})();
