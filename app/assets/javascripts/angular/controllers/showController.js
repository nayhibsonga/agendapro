(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ShowController', ShowController);

    ShowController.$inject = ['$rootScope', '$scope', 'AgendaProApi', '$routeParams'];

    function ShowController($rootScope, $scope, AgendaProApi, $routeParams) {
        var vm = this;
        vm.title = 'ShowController';
        vm.tmpl = $scope.tc.templates.show;
        vm.company = {};
        vm.currentStep = 1;
        vm.maxSteps = 2;
        vm.selectedCategory = 0;
        vm.selectedService = 0;
        vm.selectedProvider = -1;
        vm.selectService = selectService;
        vm.setStep = setStep;
        vm.schedule = activateScheduling;
        vm.scheduled = {};
        vm.serviceDetail = {};
        vm.servicesList = []; // Reservation serviced added here
        vm.showComments = false; // API TOGGLING
        vm.total = { price: 0, duration: 0 };
        vm.sortableOptions = { handle: '.handle', 'ui-floating': true, cursor: 'move' };
        vm.addService = addService;
        vm.removeService = removeService;
        vm.map = {};
        vm.categories = [];

        vm.available = {
            'Mañana': [
                {id: '1', from: '09:30', to: '10:30'},
                {id: '2', from: '10:30', to: '11:30'},
                {id: '3', from: '11:30', to: '12:30'}
                ],
            'Tarde': [
                {id: '4', from: '13:30', to: '14:30'},
                {id: '5', from: '14:30', to: '15:30'},
                {id: '6', from: '15:30', to: '16:30'},
                {id: '7', from: '16:30', to: '17:30'},
                {id: '8', from: '17:30', to: '18:30'},
                {id: '9', from: '18:30', to: '19:30'},
                {id: '10', from: '19:30', to: '19:40'},
                {id: '11', from: '19:40', to: '20:00'}
                ],
            'Noche': []
        }

        vm.sections = Object.keys(vm.available);

        AgendaProApi.show($routeParams.id).then(function(data){
            vm.company = data;
            vm.categories = vm.company.categorized_services;
            vm.map = getCompanyMap();
            vm.showComments = vm.company.show_comments;
        });

        // Main watcher for Steps
        $scope.$watch(function() {
                return vm.currentStep;
            }, function() {
                runSlider();
            });

        function selectService(category, service) {
            vm.selectedCategory = category;
            vm.selectedService = service;
            vm.serviceDetail = vm.categories[vm.selectedCategory].services[vm.selectedService];
            showOptions();
        }

        function addService(){
            vm.servicesList.push(angular.copy(vm.serviceDetail));
            calculateTotal();
        }

        function removeService(index) {
            vm.servicesList.splice(index, 1);
            calculateTotal();
        }

        function showOptions() {
            var options = $('#service-'+ vm.serviceDetail.id +'-options'),
                serviceContainer = options.closest('.service-detail'),
                closeButton = options.find('.close'),
                addButton = options.find('.add-service'),
                addContainer = addButton.closest('div'),
                customHeight = '45px',
                speed = 100;

            function bindShow() {
                options.show().animate({
                    height: customHeight
                }, speed);
            }

            function bindHide() {
                // Button close
                closeButton.on('click', function(e) {
                    e.preventDefault();
                    e.stopPropagation();
                    hideOptions();
                });

                // Mouse leaves from Container
                serviceContainer.on('mouseleave', function() {
                    hideOptions();
                });

                function hideOptions() {
                    options.animate({
                        height: '0'
                    }, speed, function(){
                        options.hide();
                    });
                }
            }

            bindShow();
            bindHide();
        }

        function activateScheduling() {
            $('#schedule').modal();
            showCalendar();
            runSlider();
        }

        function calculateTotal() {
            var price = 0;
            var mins = 0;
            for (var i = 0; i < vm.servicesList.length; i++) {
                price += parseInt(vm.servicesList[i].price || 0);
                mins += parseInt(vm.servicesList[i].duration || 0);
            };
            vm.total.price = price;
            vm.total.duration = mins;
        }

        function runSlider() {
            var states = [
                    {left: '0%', width: '50%'},
                    {left: '50%', width: '50%'}
                    ],
                currentState = states[vm.currentStep-1],
                slider = $('.slider'),
                start = slider.find('.start'),
                end = slider.find('.end');

            slider.animate({ left: currentState.left });
            slider.css('width', currentState.width);
        }

        function setStep(step) {
            // This basically controls that steps dont go
            // out of bounds
            var calc;
            if (step < 0) {
                calc = vm.currentStep - Math.abs(step);
                vm.currentStep = (calc < 0 ? 0 : calc);
            } else if (step > 0) {
                calc = vm.currentStep + (Math.abs(step) || 1);
                vm.currentStep = (calc > vm.maxSteps ? vm.maxSteps : calc);
            }
        }

        function schedule() {
            //TODO TO SCHEDULE
            return true;
        }

        function getCompanyMap() {
            var mapSettings = {};
            mapSettings = {
                center: {
                    latitude: vm.company.latitude,
                    longitude: vm.company.longitude
                },
                zoom: 14,
                marker: {
                    id: vm.company.id,
                    title: vm.company.name,
                    coords: {
                        latitude: vm.company.latitude,
                        longitude: vm.company.longitude
                    }
                }
            };
            return mapSettings;
        }

        function showCalendar() {
            $( "#datepicker" ).datepicker({
              inline: true,
              showOtherMonths: true,
              monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
              dayNamesMin: [ "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" ],
              firstDay: 1,
              prevText: "",
              nextText: "",
              dateFormat: "dd-mm-yy",
              onSelect: function(date) {
                console.log("onSelect", date);
              },
              beforeShowDay: function(date) {
                var array = ["03-11-2015","13-11-2015","23-11-2015"];
                if( $.inArray( $.datepicker.formatDate('dd-mm-yy', date), array) > -1 ) {
                    return [true,"deal-day",''];
                } else {
                    return [true,'',''];
                }
              }
            });
        }

    }
})();
