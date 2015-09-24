'use strict'

angular.module('HoraChic').
  controller('TemplateController', ['$scope', function($scope) {
    $scope.country = 'cl';
    $scope.lang = Translations($scope.country);
    $scope.templates = {
      landing: '/hora_chic/landing'
      };
    // To render a new element in the main content
    // section, just change the route to the template
    // In shits scope.
    $scope.template = $scope.templates.landing;
  }]);

