(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ShowController', ShowController);

    ShowController.$inject = ['$rootScope', '$scope', 'AgendaProApi'];

    function ShowController($rootScope, $scope, Api) {
        var vm = this;
        vm.title = 'ShowController';
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
        vm.showComments = true; // API TOGGLING
        vm.total = { price: 0, time: 0 };
        vm.sortableOptions = { handle: '.handle', 'ui-floating': true, cursor: 'move' };

        //Service CRUD
        vm.addService = addService;
        vm.removeService = removeService;
        vm.updateService = updateService;

        vm.categories = [
            {id: 1, name: 'Corte de Pelo', services: [
                {id: 1, title: 'Decoloración Completa pelo corto mediano y largo', price: 15900, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
                {id: 2, title: 'Decoloración', price: 9900, time: '1 hr', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]}
            ]},
            {id: 2, name: 'Manicure', services: [
                {id: 3, title: 'Manicure Express', price: 7000, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
                {id: 4, title: 'Manicure SPA', price: 10900, time: '1 hr 40 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 6, name: 'Christian Moreno'}]},
                {id: 5, title: 'Uñas Acrilicas Francesa', price: 35000, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'}]},
                {id: 6, title: 'Cambio de esmalte', price: 6000, time: '1 hr', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 6, name: 'Christian Moreno'}]}
            ]}
        ];

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

        function updateService(obj) {
            var keys = Object.keys(obj);
            for (var i = 0; i < keys.length; i++) {
                keys[i];
            };
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
            for (var i = 0; i < vm.servicesList.length; i++) {
                price += vm.servicesList[i].price;
                // vm.total.time += vm.servicesList[i].service.time;
            };
            vm.total.price = price;
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

    }
})();
