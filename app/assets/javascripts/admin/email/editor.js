//= require editor/angular.min
//= require editor/angular-file-upload.min

(function() {
  'use strict';
  var app = angular.module('AgendaProApp', ['angularFileUpload']);

  app
    .directive('customCkEditor', customCkEditor)
    .controller('EditorController', EditorController);

  EditorController.$inject = ['$scope', 'FileUploader', '$http'];

  function EditorController($scope, FileUploader, $http) {
    var vm = this;
    vm.active = '';
    vm.content = JSON.parse(angular.element('#content-data').val());
    vm.uploader = new FileUploader({
      url: '/email_content/upload',
      autoUpload: true,
      headers : {
        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
      },
      formData: [{id: vm.content.id}]
    });
    vm.activeImage = '';
    vm.send_email = false;

    vm.selectFile = selectFile;
    vm.saveContent = saveContent;

    vm.uploader.onCompleteItem = function(fileItem, response, status, headers) {
        if( status == 200 ) {
          vm.content.data[vm.activeImage] = response.url;
        } else {
          vm.error = "Error uploading image ".concat(status);
        }
    };

    function selectFile(event, imgName) {
      vm.activeImage = imgName;
      angular.element(event.target).next().click();
    }

    function saveContent(url) {
      console.log(url);
      return $http.post(url, buildData()).then(function(response){
        return response;
      }, ShowError);
    }

    function buildData() {
      var content = vm.content;
      return {
        id: content.id,
        send_email: vm.send_email,
        content: {
          to: content.to,
          from: content.from,
          subject: content.subject,
          data: content.data
        }
      }
    }

    function ShowError(response) {
      vm.error = response;
      return vm.error;
    }
  }

  function customCkEditor() {
      return {
          require: '?ngModel',
          link: function ($scope, elm, attr, ngModel) {
              var ck = CKEDITOR.instances[elm[0].id];

              ck.on('change', function() {
                  $scope.$apply(function () {
                      ngModel.$setViewValue(ck.getData());
                  });
              });

              ngModel.$render = function (value) {
                  ck.setData(ngModel.$modelValue);
              };

              $scope.$on("$destroy",function() {
                  ck.destroy();
              });
          }
      };
  }

})();
