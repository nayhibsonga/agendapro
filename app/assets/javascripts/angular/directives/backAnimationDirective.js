(function() {
    'use strict';

    angular
        .module('HoraChic')
        .directive('backAnimation', backAnimation);

    backAnimation.$inject = ['$browser', '$location'];

    function backAnimation($browser, $location) {
        // Usage:
        //
        // Creates:
        //
        var directive = { link: link };

        return directive;

        function link(scope, element, attrs) {
          $browser.onUrlChange(function(newUrl) {
            if ($location.absUrl() === newUrl) {
              console.log('Back');
              element.addClass('reverse');
            }
          });

          scope.__childrenCount = 0;
          scope.$watch(function() {
            scope.__childrenCount = element.children().length;
          });

          scope.$watch('__childrenCount', function(newCount, oldCount) {
            if (newCount !== oldCount && newCount === 1) {
              element.removeClass('reverse');
            }
          });
        }
    }

})();
