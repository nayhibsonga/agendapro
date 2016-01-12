//= require editor/angular.min
//= require editor/angular-file-upload.min

(function() {
  'use strict';
  var app = angular.module('AgendaProApp', ['angularFileUpload']);

  app.controller('EditorController', EditorController);

  EditorController.$inject = ['$scope', 'FileUploader'];

  function EditorController($scope, FileUploader) {
    var vm = this;
    vm.active = '';
    vm.data = {
      from: 'QUE TE IMPORTA',
      recipients: '',
      subject: '',
      content: {}
    };
    vm.uploader = new FileUploader({
      url: '/email_content/upload',
      autoUpload: true,
      headers : {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      }
    });

    vm.uploader.onCompleteItem = function(fileItem, response, status, headers) {
        console.log('onCompleteItem', fileItem, response, status, headers);
    };

  }
})();
