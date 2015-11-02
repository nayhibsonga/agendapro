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
        vm.servicesList = [];
        vm.showComments = false; // API TOGGLING
        vm.total = { price: 0, duration: 0 };
        vm.sortableOptions = { handle: '.handle', 'ui-floating': true, cursor: 'move' };
        vm.addService = addService;
        vm.removeService = removeService;
        vm.map = {};
        vm.categories = [];

        // vm.categories = [
        //     {id: 1, name: 'Corte de Pelo', services: [
        //         {id: 1, name: 'Decoloración Completa pelo corto mediano y largo', price: 15900, duration: 90, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
        //         {id: 2, name: 'Decoloración', price: 9900, duration: 60, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]}
        //     ]},
        //     {id: 2, name: 'Manicure', services: [
        //         {id: 3, name: 'Manicure Express', price: 7000, duration: 90, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
        //         {id: 4, name: 'Manicure SPA', price: 10900, duration: 100, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 6, name: 'Christian Moreno'}]},
        //         {id: 5, name: 'Uñas Acrilicas Francesa', price: 35000, duration: 90, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'}]},
        //         {id: 6, name: 'Cambio de esmalte', price: 6000, duration: 60, description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 6, name: 'Christian Moreno'}]}
        //     ]}
        // ];

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
                customHeight = '30%',
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

    }
})();
