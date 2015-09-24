'use strict'

angular.module('HoraChic').
  controller('LinksController', ['$scope', function($scope) {
    var $namespace = "/hora_chic/";
    $scope.services = [
      { name: 'peluquerias', url: $namespace + 'peluquerias'},
      { name: 'maquillaje', url: $namespace + 'maquillaje'},
      { name: 'estetica', url: $namespace + 'estetica'},
      { name: 'spa', url: $namespace + 'spa'},
      { name: 'tratamientos', url: $namespace + 'tratamientos'},
      { name: 'manos_y_pies', url: $namespace + 'manos-y-pies'},
      { name: 'deals', url: $namespace + 'promociones'},
      { name: 'blog', url: $namespace + 'blog'},
      ];

    $scope.social = [
      { name: 'facebook', url: 'https://www.facebook.com/agendapro' },
      { name: 'twitter', url: 'https://twitter.com/AgendaPro_CL' },
      { name: 'instagram', url: 'https://instagram.com/agendapro/' }
    ];

  }]);
