(function() {
    'use strict';

    angular
        .module('HoraChic')
        .filter('dealsCurrency', dealsCurrency);

    function dealsCurrency() {
        return dealsCurrencyFilter;

        function dealsCurrencyFilter(price) {
            return price.replace(',','.');
        }
    }

})();
