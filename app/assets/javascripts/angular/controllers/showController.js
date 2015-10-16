(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ShowController', ShowController);

    ShowController.$inject = ['$rootScope', '$scope'];

    function ShowController($rootScope, $scope) {
        var vm = this;
        vm.title = 'ShowController';
        vm.currentStep = 1;
        vm.maxSteps = 3;
        vm.scheduled = {};
        vm.selectedCategory = 0;
        vm.selectedService = 0;
        vm.selectedProvider = 0;
        vm.selectService = selectService;
        vm.setStep = setStep;
        vm.serviceDetail = {};
        vm.schedule = schedule;
        vm.servicesList = {};
        vm.addService = addService;
        vm.removeService = removeService;
        vm.total = { price: 15900, time: 0 };

        vm.categories = [
            {id: 1, name: 'Corte de Pelo', services: [
                {id: 1, title: 'Decoloracion Completa pelo corto mediano y largo', price: 15900, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
                {id: 2, title: 'Decoloracion', price: 9900, time: '1 hr', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]}
            ]},
            {id: 2, name: 'Manicure', services: [
                {id: 3, title: 'Manicure Express', price: 7000, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'},{id: 6, name: 'Christian Moreno'}]},
                {id: 4, title: 'Manicure SPA', price: 10900, time: '1 hr 40 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 2, name: 'Manuel Perez'},{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 6, name: 'Christian Moreno'}]},
                {id: 5, title: 'Uñas Acrilicas Francesa', price: 35000, time: '1 hr 30 min', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae.', providers: [{id: 3, name: 'Jesus De Nazareth'},{id: 4, name: 'Celine Dion'},{id: 5, name: 'Antonio Banderas'}]},
                {id: 6, title: 'Cambio de esmalte', price: 6000, time: '1 hr', description: 'Lorem ipsum dolor sit amet, consectetur adipisicing elit. Iusto consequatur perferendis odio quis natus rerum quod, laboriosam minus modi nostrum totam iure ipsam mollitia tenetur, doloribus minima, nihil autem! Recusandae. Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ad incidunt alias modi rerum totam, aspernatur accusantium doloremque. Ab reprehenderit tenetur, voluptatibus est, ipsam veritatis, fugiat neque nemo quis tempore quidem.', providers: [{id: 1, name: 'Rodrigo Ramirez'},{id: 6, name: 'Christian Moreno'}]}
            ]}
        ];

        vm.servicesList = [];

        // vm.servicesList = [
        //     {
        //         service: { id: 1, title: 'Decoloracion Completa pelo corto mediano y largo', price: 15900, time: '1 hr 30 min'},
        //         provider: { id: 4, name: 'Celine Dion' }
        //     }
        // ];

        // Main watcher for Steps
        $scope.$watch(function() {
                return vm.currentStep;
            }, function() {
                runSlider();
                //ADD CONTROL FOR BUTTONS
            });

        function selectService(category, index) {
            vm.selectedCategory = category;
            vm.selectedService = index;
            activateScheduling();
        }

        function activateScheduling() {
            vm.serviceDetail = vm.categories[vm.selectedCategory].services[vm.selectedService];
            $('#schedule').modal();
            runSlider();
        }

        function addService() {
            var newItem = {service: {}, provider: {}},
                service = vm.serviceDetail;
            newItem.provider = service.providers[vm.selectedProvider] || { id: -1, name: 'Cualquier Prestador' };
            newItem.service = {id: service.id, title: service.title, time: service.time, price: service.price};
            vm.servicesList.push(newItem);
            calculateTotal();
        }

        function removeService(index) {
            vm.servicesList.splice(index, 1);
            calculateTotal();
        }

        function calculateTotal() {
            var price = 0;
            for (var i = 0; i < vm.servicesList.length; i++) {
                price += vm.servicesList[i].service.price;
                // vm.total.time += vm.servicesList[i].service.time;
            };
            vm.total.price = price;
        }

        function runSlider() {
            var states = [
                    {left: '0%', width: '31.4%'},
                    {left: '31.3%', width: '33.4%'},
                    {left: '64.6%', width: '35.4%'}
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
