(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('ShowController', ShowController);

    ShowController.$inject = ['$rootScope', '$scope', 'AgendaProApi', '$routeParams', '$location'];

    function ShowController($rootScope, $scope, AgendaProApi, $routeParams, $location) {
        var vm = this;
        vm.title = 'ShowController';
        vm.tmpl = $scope.tc.templates.show;
        vm.company = {};
        vm.companyLoaded = false;
        vm.currentStep = 1;
        vm.maxSteps = 2;
        vm.selectedCategory = 0;
        vm.selectedService = 0;
        vm.selectedProvider = -1;
        vm.scheduled = {};
        vm.serviceDetail = {};
        vm.servicesList = []; // Reservation serviced added here
        vm.showComments = false; // API TOGGLING
        vm.availableHours = {};
        vm.sections = [];
        vm.map = {};
        vm.categories = [];
        vm.user = {};
        vm.total = { price: 0, duration: 0 };
        vm.sortableOptions = { handle: '.handle', 'ui-floating': true, cursor: 'move' };

        vm.selectService = selectService;
        vm.setStep = setStep;
        vm.schedule = schedule;
        vm.addService = addService;
        vm.removeService = removeService;
        vm.mobileSummary = mobileSummary;
        vm.setAppointment = setAppointment;
        vm.submitBooking = submitBooking;

        AgendaProApi.show($routeParams.id).then(function(data){
            vm.company = data;
            vm.companyLoaded = true;
            vm.categories = vm.company.categorized_services;
            vm.map = getCompanyMap();
            vm.showComments = vm.company.show_comments;
            showCalendar();
        });

        // Main watcher for Steps
        $scope.$watch(function() {
                return vm.currentStep;
            }, function() {
                runSlider();
            });

        $scope.$watch(function() {
            return vm.availableHours;
        }, function() {
            vm.sections = Object.keys(vm.availableHours).slice(0,3);
        })

        $scope.$on('$includeContentLoaded', function (e, tmpl) {
            var step1 = vm.tmpl.step1,
                loadedCompany = Object.keys(vm.company).length > 0;
            if( tmpl === step1 && loadedCompany ) {
                showCalendar();
            }
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

        function schedule() {
            $('#schedule').modal();
            getAvailableHours();
            runSlider();
        }

        function getAvailableHours(date) {
            var date = (date || new Date());
            vm.availableHours = {};
            AgendaProApi.weeklyHours(date, $routeParams.id, vm.servicesList)
                .then( function(response) {
                    vm.availableHours = response;
                }
            );
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

        function submitBooking() {
            var data = {},
                bookings = [];

            for (var i = 0; i < vm.servicesList.length; i++) {
              bookings.push(vm.servicesList[i].appointment);
            };

            data.location_id = $routeParams.id;
            data.payment = '0';
            data.max_discount = '0';
            data.has_sessions = '0';
            data.mp = '';

            data.bookings = {bookings: bookings};
            data.client = vm.user;

            AgendaProApi.sendBooking(data).then(function(response, status) {
                if ( status === 200 ) {
                    $location.path('/booking/success/1/1234567');
                }
            });
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
            $("#datepicker").datepicker({
              inline: true,
              showOtherMonths: false,
              monthNames: ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'],
              dayNamesMin: [ "Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb" ],
              firstDay: 1,
              prevText: "",
              nextText: "",
              dateFormat: "yy-mm-dd",
              hideIfNoPrevNext: true,
              minDate: "0m",
              maxDate: "+6m",
              onSelect: function(date) {
                getAvailableHours(date);
              },
              beforeShowDay: function(date) {
                var dateFormatted = $.datepicker.formatDate('yy-mm-dd', date),
                    dayName = $.datepicker.formatDate('DD', date),
                    mappedDays = { 'Monday': 'Lunes', 'Tuesday': 'Martes', 'Wednesday': 'Miércoles', 'Thursday': 'Jueves', 'Friday': 'Viernes', 'Saturday': 'Sábado', 'Sunday': 'Domingo' },
                    klass = '',
                    show = false;

                if ( localOpensThisDay() ) {
                    if ( isDealDay() ) { klass += 'deal-day' }
                    show = true;
                }

                return [show, klass, ''];

                function isDealDay() {
                    var dealDays = ["2015-11-03","2015-11-13","2015-11-23"];
                    return $.inArray( dateFormatted, dealDays ) > -1;
                }

                function localOpensThisDay() {
                    var openedDays = vm.company.location_times,
                        days = [];
                    for (var i = 0; i < openedDays.length; i++) {
                        days.push(openedDays[i].long_day);
                    };

                    return $.inArray( mappedDays[dayName], days ) > -1;
                }
              }
            });
        }

        // Toggler for Mobile Bubble, and
        // sets the container Height.

        function mobileSummary() {
            var btn = $('#summary-button'),
                content = $('#summary-detail-xs'),
                contentHeight = content.height(),
                contentAutoHeight = content.css('height', 'auto').height();

            if( btn.hasClass('pressed') ) {
                contentAutoHeight = 0;
            }

            btn.toggleClass('pressed');

            content.height(contentHeight).animate({
                height: contentAutoHeight
            }, 400, function() {
                if( btn.hasClass('pressed') ) {
                    content.css('height', 'auto');
                }
            });
        }

        // When an Hour is selected, this sets all
        // booking hours to listed services (Appointmets)

        function setAppointment(section, index) {
            var section = vm.availableHours[section],
                bookings = section[index].bookings;

            for (var i = 0; i < vm.servicesList.length; i++) {
                vm.servicesList[i].appointment = {
                    service_id: bookings[i].service,
                    provider_id: bookings[i].provider_id,
                    start: bookings[i].start,
                    end: bookings[i].end,
                    provider_lock: bookings[i].provider_lock,
                    price: bookings[i].price
                }
            };

        }

    }
})();
