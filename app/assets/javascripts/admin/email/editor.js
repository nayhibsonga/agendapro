//= require editor/angular.min
//= require editor/angular-file-upload.min

(function() {
  'use strict';
  var app = angular.module('AgendaProApp', []);

  app.controller('EditorController', EditorController);

  EditorController.$inject = ['$scope'];

  function EditorController($scope) {
    var vm = this;
    vm.active = '';
    vm.data = {
      from: 'QUE TE IMPORTA',
      recipients: '',
      subject: '',
      content: {}
    };
  }
})();
