(function() {
    'use strict';

    angular
        .module('HoraChic')
        .filter('dealsCurrency', dealsCurrency)
        .filter('startFrom', startFrom)
        .filter('clp', clp)
        .filter('inHours', inHours)
        .filter('appointmentDates', appointmentDates)
        .filter('sanitize', sanitize)
        .filter('discountFormat', discountFormat);

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

    function inHours() {
        return inHoursFilter;

        function inHoursFilter(mins) {
            var total = Math.round((parseFloat(mins)/60)*100)/100,
                hours = Math.floor(total),
                minutes = Math.round(parseFloat('0.'+ total.toString().split('.')[1]) * 100 ) / 100,
                result = "";

            if( hours === 0) {
                return mins + ' mins';
            } else {
                var str = (hours === 1 ? ' hr' : ' hrs');
                result += hours.toString() + str;
            }

            if( !isNaN(minutes) && minutes !== 0 ) {
                minutes = Math.round(minutes * 60);
                result += ' ' + minutes.toString() + ' mins';
            }

            return result;
        }
    }

    function appointmentDates() {
        return appointmentDatesFilter;

        function appointmentDatesFilter(appointment) {
            var dateRange = "";

            if( angular.isUndefined(appointment) ) {
                dateRange = "No ha seleccionado hora";
            } else {
                dateRange += appointment.start.split("T")[1].slice(0,5);
                dateRange += " - ";
                dateRange += appointment.end.split("T")[1].slice(0,5);
            }

            return dateRange;
        }
    }

    function sanitize($sce) {
        return sanitizeFilter;

        function sanitizeFilter(html) {
            return $sce.trustAsHtml(html);
        }
    }
    sanitize.$inject = ["$sce"];

    function discountFormat() {
        return discountFormatFilter;

        function discountFormatFilter(str) {
            return str.slice(1);
        }
    }



})();
