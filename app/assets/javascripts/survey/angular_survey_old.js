angular.module('survey', ["checklist-model"])
.controller('InvoiceController', function ($scope) {
    $scope.roles = [
      '#{@company.name}',
      'user',
      'customer',
      'admin'
    ];
    $scope.user = {
      roles: ['user']
    };

  $scope.add_question = function(){
    console.log($scope.user.roles)
  }
});
