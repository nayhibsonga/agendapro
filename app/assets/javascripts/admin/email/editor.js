//= require editor/angular.min
//= require editor/angular-file-upload.min
//= require editor/toastr.min

(function() {
  'use strict';
  var app = angular.module('AgendaProApp', ['angularFileUpload']);

  app
    .directive('customCkEditor', customCkEditor)
    .directive('dynamic', dynamic)
    .controller('EditorController', EditorController);

  EditorController.$inject = ['$scope', 'FileUploader', '$http'];

  function EditorController($scope, FileUploader, $http) {
    var vm = this;
    var csrfToken = document.querySelector('meta[name="csrf-token"]').getAttribute('content');
    vm.active = '';
    vm.content = JSON.parse(angular.element('#content-data').val());
    vm.uploader = new FileUploader({
      url: 'upload',
      autoUpload: true,
      headers : {
        'X-CSRF-TOKEN': csrfToken
      },
      formData: [{id: vm.content.id}]
    });
    vm.activeImage = '';
    vm.send_email = false;
    vm.pageLoaded = false;
    vm.notice = '';
    vm.activeEditor = '';

    vm.editText = editText;
    vm.selectFile = selectFile;
    vm.saveContent = saveContent;
    vm.validContent = validContent;

    ckEditorInit();
    toastrInit();

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
      $http.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken;
      if( vm.send_email ) {
        vm.validContent() ? saveAndSend() : showValidationError();
      } else {
        quickSave();
      }

      function saveAndSend() {
        swal({
          title: "¿Estás seguro?",
          text: "Este correo será enviado a todos los destinatarios",
          type: "info",
          showCancelButton: true,
          closeOnConfirm: false,
          showLoaderOnConfirm: true,
        }, function(){
          $http.post(url, buildData()).then(function(response){
            swal("¡Enviado!", "Serás redireccionado en unos instantes", "success");
            setTimeout(function(){
              location.href = response.data.url;
            }, 3000);
          }, ShowError);
        });
      }

      function quickSave() {
        toastr.info("Guardando ...");
        $http.post(url, buildData()).then(function(response){
          toastr.success("Guardado!");
        }, ShowError);
      }

      function showValidationError() {
        swal("Ooops", "Por favor completa los campos antes de enviar", "warning");
      }
    }

    function editText(name) {
      if (vm.activeEditor !== '') {
        CKEDITOR.instances[vm.activeEditor].destroy();
      }
      vm.activeEditor = name.replace('text', 'editor');
      CKEDITOR.appendTo('editorSpace', null, vm.content.data[name]);
      ckEditorListeners();
    }

    function ckEditorListeners() {
      var instance = CKEDITOR.instances[vm.activeEditor];
      instance.on('change', function() {
          vm.content.data[vm.activeEditor.replace('editor', 'text')] = instance.getData();
          $scope.$apply();
      });
    }

    function buildData() {
      var content = vm.content;
      return {
        content: {
          id: content.id,
          send_email: vm.send_email,
          to: content.to,
          from: content.from,
          subject: content.subject,
          data: content.data
        }
      }
    }

    function validContent() {
      return
        Object.keys(vm.content.data).length > 0 &&
        vm.content.subject &&
        vm.content.subject.length > 0;
    }

    function ShowError(response) {
      vm.error = response;
      return vm.error;
    }

    function ckEditorStatus() {
      CKEDITOR.on('instanceReady',function(){
         vm.pageLoaded = true;
         $scope.$apply();
      });
    }


  }

  function ckEditorInit() {
    CKEDITOR.config.removePlugins = 'image';
    CKEDITOR.config.toolbar_mini = [
      ["Bold",  "Italic",  "Underline",  "Strike",  "-",  "Subscript",  "Superscript"],
    ];
    CKEDITOR.config.toolbar = "simple";
    CKEDITOR.config.uiColor = '#FFFFFF';
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

  function dynamic($compile) {
    return {
      restrict: 'A',
      replace: true,
      link: function (scope, ele, attrs) {
        scope.$watch(attrs.dynamic, function(html) {
          ele.html(html);
          $compile(ele.contents())(scope);
        });
      }
    };
  }

  function toastrInit() {
    toastr.options = {
      "closeButton": false,
      "debug": false,
      "newestOnTop": false,
      "progressBar": false,
      "positionClass": "toast-top-center",
      "preventDuplicates": true,
      "onclick": null,
      "showDuration": "300",
      "hideDuration": "1000",
      "timeOut": "2000",
      "extendedTimeOut": "1000",
      "showEasing": "swing",
      "hideEasing": "linear",
      "showMethod": "fadeIn",
      "hideMethod": "fadeOut"
    }
  }
})();
