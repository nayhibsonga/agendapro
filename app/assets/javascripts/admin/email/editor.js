//= require editor/angular.min
//= require editor/angular-file-upload.min
//= require editor/toastr.min

(function() {
  'use strict';
  var app = angular.module('AgendaProApp', ['angularFileUpload']);

  app
    .directive('dynamic', dynamic)
    .controller('EditorController', EditorController);

  dynamic.$inject = ['$compile'];
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
    vm.activeEditor = '';

    vm.editText = editText;
    vm.selectFile = selectFile;
    vm.saveContent = saveContent;

    ckEditorInit();
    toastrInit();

    vm.uploader.onCompleteItem = function(fileItem, response, status, headers) {
        if( status == 200 ) {
          vm.content.data[vm.activeImage] = response.url;
        } else {
          toastr.warning("Ocurrió un error al subir la imagen (" + status +")");
        }
    };

    function selectFile(event, imgName) {
      vm.activeImage = imgName;
      angular.element(event.target).next().click();
    }

    function saveContent(url) {
      $http.defaults.headers.common['X-CSRF-TOKEN'] = csrfToken;
      if( vm.send_email ) {
        validContent() ? saveAndSend() : showValidationError();
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
        }, function() {
          $http.post(url, buildData()).then(function(response){
            swal("¡Enviado!", "Serás redireccionado en unos instantes", "success");
            setTimeout(function(){
              location.href = response.data.url;
            }, 2500);
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

    function editText(selectedIndex) {
      if (vm.activeEditor !== '') {
        CKEDITOR.instances[vm.activeEditor].destroy();
      }
      CKEDITOR.appendTo('editorSpace', null, vm.content.data[selectedIndex]);
      vm.activeEditor = Object.keys(CKEDITOR.instances)[0];
      ckEditorListeners(selectedIndex);
    }

    function ckEditorListeners(source) {
      var instance = CKEDITOR.instances[vm.activeEditor];
      instance.on('change', function() {
          vm.content.data[source] = instance.getData();
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
      return (Object.keys(vm.content.data).length > 0 &&
        angular.isDefined(vm.content.subject) &&
        vm.content.subject.length > 0);
    }

    function ShowError(response) {
      toastr.success("Error: " + response.toString());
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
