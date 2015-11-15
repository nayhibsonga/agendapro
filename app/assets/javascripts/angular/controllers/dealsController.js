(function() {
    'use strict';

    angular
        .module('HoraChic')
        .controller('DealsController', DealsController);

    DealsController.$inject = ['AgendaProApi', '$routeParams', '$location', '$rootScope', '$scope'];

    function DealsController(AgendaProApi, $routeParams, $location, $rootScope, $scope) {
        var vm = this;
        vm.tmpl = $scope.tc.templates.deals;
        vm.deals = [];
        vm.showTitle = true;
        vm.dealId = $routeParams.id;
        vm.locationId = $routeParams.location_id;
        vm.loadDeal = loadDeal;
        vm.fetchDeals = fetchDeals;
        vm.fetchPreview = fetchPreview;
        vm.showDeal = showDeal;
        vm.error = '';

        if( vm.dealId && vm.locationId ) {
            loadDeal()
        }

        function loadDeal() {
            vm.currentStep = 1;
            vm.maxSteps = 2;
            vm.selectedCategory = 0;
            vm.selectedService = 0;
            vm.servicesList = []; // Reservation serviced added here
            vm.availableHours = {};
            vm.sections = [];
            vm.map = {};
            vm.categories = [];
            vm.user = {};
            vm.deal = {};
            vm.loaded = false;

            vm.setStep = setStep;
            vm.schedule = schedule;
            vm.setAppointment = setAppointment;
            vm.submitBooking = submitBooking;

            AgendaProApi.deal(vm.dealId, vm.locationId).then(function(data){
              vm.deal = data;
              vm.map = getCompanyMap();
              vm.loaded = true;
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
                var step1 = vm.tmpl.step1;
                if( tmpl === step1 ) {
                    showCalendar();
                }
            });

            function schedule() {
                $('#schedule').modal();
                getAvailableHours();
                runSlider();
            }

            function getAvailableHours(date) {
                var date = (date || new Date());
                vm.availableHours = {};
                AgendaProApi.weeklyHours(date, vm.locationId, [vm.deal])
                    .then( function(response) {
                        vm.availableHours = response;
                    }
                );
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

                data.location_id = $routeParams.location_id;
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
                        latitude: vm.deal.latitude,
                        longitude: vm.deal.longitude
                    },
                    zoom: 14,
                    marker: {
                        id: vm.deal.id,
                        title: vm.deal.company_name,
                        coords: {
                            latitude: vm.deal.latitude,
                            longitude: vm.deal.longitude
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
                        klass = '';

                    return [true, klass, ''];
                  }
                });
            }

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

        function showDeal(deal) {
            var url = $rootScope.baseUrl + '/deals/' + deal.id + '?location_id=' + deal.location_id;
            console.log(url);
            $location.url(url);
        }

        function fetchDeals() {
            console.log("ALL");
            // Resolve Deals
            AgendaProApi.deals().then(function(data){
              vm.deals = data;
            });
        }

        function fetchPreview() {
            console.log("PREVIEW");
            // Resolve Deals Preview
            AgendaProApi.deals_preview().then(function(data){
              vm.deals = data;
            });
        }

    }
})();
