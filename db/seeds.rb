# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


status = Status.create(name: "Reservado", description: "Reserva sólo ha sido agendada")

tags = Tag.create(name: "Corte de Pelo")

transaction_types = TransactionType.create(name: "Webpay", description: "El usuario paga por webpay")

payment_statuses = PaymentStatus.create(name: "Al día", description: "La empresa tiene todos los pagos al día")

economic_sectors = EconomicSector.create(name: "Peluquería")

countries = Country.create(name: "Chile")

regions = Region.create(name: "Metropolitana", country: countries)

cities = City.create(name: "Santiago", region: regions)

district = District.create(name: "Las Condes", city: cities)

days = Day.create([{name: "Lunes"}, {name: "Martes"}, {name: "Miércoles"}, {name: "Jueves"}, {name: "Viernes"}, {name: "Sábado"}, {name: "Domingo"}])

plans = Plan.create(name: "Básico", locations: 3, staffs: 10, custom: false, price: 12000, special: true)

roles = Role.create([{name: "Super Admin", description: "Administrador de la aplicaión AgendaPro"}, {name: "Admin", description: "Administrador de empresa inscrita en AgendaPro"}, {name: "Administrador Local", description: "Administrador de local"}, {name: "Staff", description: "Usuario con atribuciones de atención en su local"}, {name: "Usuario Registrado", description: "Usuario con cuenta registrada y accesible"}, {name: "Usuario No Registrado", description: "Usuario con cuenta no registrada"}])

admin = User.create(first_name: 'Sebastián', last_name: 'Hevia', email: 'sebastianhevia@gmail.com', phone: '12345678', role: Role.find_by_name('Super Admin'), user_name: 'shevia', password: '12345678', password_confirmation: '12345678')

company = Company.create(name: 'Company Test', web_address: 'test', economic_sector_id: 1, plan_id: 1, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

local = Location.create(name: 'Test Location', address: 'Calle 123', phone: '+560222588552', district_id: 1, company_id: 1)

location_times = LocationTime.create([{open: '15:00', close: '20:00', location_id: 1, day_id: 1}, {open: '15:00', close: '20:00', location_id: 1, day_id: 3}, {open: '15:00', close: '20:00', location_id: 1, day_id: 2}, {open: '08:30', close: '13:30', location_id: 1, day_id: 5}, {open: '08:30', close: '10:00', location_id: 1, day_id: 3}, {open: '08:30', close: '13:30', location_id: 1, day_id: 1}, {open: '11:00', close: '13:30', location_id: 1, day_id: 3}, {open: '11:30', close: '13:30', location_id: 1, day_id: 4}, {open: '09:30', close: '13:30', location_id: 1, day_id: 2}, {open: '15:00', close: '17:00', location_id: 1, day_id: 4}])

service_provider = ServiceProvider.create(location_id: 1, user_id: 1, company_id: 1)

service = Service.create([{name: "Corte de pelo", price: 2500, duration: 5, company_id: 1, tag_id: 1}, {name: "Vicios", price: 5000, duration: 15, company_id: 1, tag_id: 1}])

service_provider.services << service

provider_times = ProviderTime.create([{open: '8:30', close: '20:00', service_provider_id: 1, day_id: 1}, {open: '10:30', close: '19:30', service_provider_id: 1, day_id: 2}, {open: '14:00', close: '17:00', service_provider_id: 1, day_id: 3}, {open: '8:00', close: '20:30', service_provider_id: 1, day_id: 4}, {open: '9:00', close: '18:00', service_provider_id: 1, day_id: 5}])

bookings = Booking.create([{start: '2013-12-26T08:30z', end: '2013-12-26T10:00', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1}, {start: '2013-12-26T13:30z', end: '2013-12-26T15:30', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1}, {start: '2013-12-27T010:00z', end: '2013-12-27T12:00', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1}, {start: '2013-12-30T16:30z', end: '2013-12-30T18:30', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1}, {start: '2013-12-26T08:30z', end: '2013-12-26T10:00', service_provider_id: 1, user_id: 1, service_id: 2, location_id: 1, status_id: 1}])