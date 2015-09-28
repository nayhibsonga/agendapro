(function (){
  'use strict'

  angular
    .module('HoraChic')
    .controller('TemplateController', TemplateController);

  TemplateController.$inject = ['Translator'];

  function TemplateController(Translator) {
    var vm = this;
    vm.lang = Translator.init();
    vm.templates = {
      landing: '/hora_chic/landing'
      };
    // To render a new element in the main content
    // section, just change the route to the template
    // In shits scope.
    vm.template = vm.templates.landing;
  }
})();
