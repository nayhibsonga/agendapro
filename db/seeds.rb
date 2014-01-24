# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Status de las Reservas
status = Status.create(name: "Reservado", description: "Reserva sólo ha sido agendada")
status = Status.create(name: "Bloqueado", description: "Hora no disponible bloqueada porel local")
status = Status.create(name: "Disponible", description: "Hora disponible para reservar")
status = Status.create(name: "Completado", description: "Reserva sólo ha sido agendada")
status = Status.create(name: "Pagado", description: "Cliente pre-pago la cita")
status = Status.create(name: "Confirmado", description: "Reserva sólo ha sido agendada")
status = Status.create(name: "Cancelado", description: "Reserva sólo ha sido agendada")
status = Status.create(name: "No Show", description: "Cliente no llego a la cita")

# Forma de pago de las Empresas
transaction_types = TransactionType.create(name: "Webpay", description: "El usuario paga por webpay")
transaction_types = TransactionType.create(name: "Transferencia", description: "El usuario paga por trasferencia bancaria")

# Estado de Pago de las Empresas
payment_statuses = PaymentStatus.create(name: "Al día", description: "La empresa tiene todos los pagos al día")
payment_statuses = PaymentStatus.create(name: "Período de Prueba", description: "La empresa está en período de prueba")
payment_statuses = PaymentStatus.create(name: "Atrasada", description: "La empresa está atrasada en el pago del mes en curso")
payment_statuses = PaymentStatus.create(name: "Bloqueada", description: "La empresa está bloqueada por no pago del plan")

# Sectores Eonómicos de las Empresas
economic_sectors = EconomicSector.create(name: "Centros de Estética")
economic_sectors = EconomicSector.create(name: "Medicina Alternativa")
economic_sectors = EconomicSector.create(name: "Sicología")
economic_sectors = EconomicSector.create(name: "Dentistas")
economic_sectors = EconomicSector.create(name: "Talleres Mecánicos")
economic_sectors = EconomicSector.create(name: "Podología")

# Tags para la búsqueda
tags = Tag.create([{name: "Corte de Pelo", economic_sector_id: 1}, {name: "Tinturas", economic_sector_id: 1}, {name: "Masajes", economic_sector_id: 1}, {name: "Tratamientos Especiales", economic_sector_id: 2}])

# Países Activos
countries = Country.create(name: "Chile")

# Regiones de los países activos 
regions = Region.create(name: "Metropolitana", country: countries)

# Ciudades Activas 
cities = City.create(name: "Santiago", region: regions)

# Comunas Activas 
district = District.create(name: "Las Condes", city: cities)
district = District.create(name: "Providencia", city: cities)
district = District.create(name: "Vitacura", city: cities)
district = District.create(name: "Ñuñoa", city: cities)
district = District.create(name: "Santiago", city: cities)
district = District.create(name: "Lo Barnechea", city: cities)
district = District.create(name: "La Florida", city: cities)
district = District.create(name: "La Reina", city: cities)

days = Day.create([{name: "Lunes"}, {name: "Martes"}, {name: "Miércoles"}, {name: "Jueves"}, {name: "Viernes"}, {name: "Sábado"}, {name: "Domingo"}])

# Planes Disponibles
plans = Plan.create(name: "Personal", locations: 1, service_providers: 1, custom: false, price: 14900, special: false)
plans = Plan.create(name: "Básico", locations: 1, service_providers: 30, custom: false, price: 24900, special: false)
plans = Plan.create(name: "Normal", locations: 2, service_providers: 60, custom: false, price: 39900, special: false)
plans = Plan.create(name: "Premium", locations: 3, service_providers: 90, custom: false, price: 49900, special: false)

# Roles de la Aplicación 
# ARREGLAR POR SEBA
roles = Role.create([{name: "Super Admin", description: "Administrador de la aplicaión AgendaPro"}, {name: "Admin", description: "Administrador de empresa inscrita en AgendaPro"}, {name: "Administrador Local", description: "Administrador de local"}, {name: "Staff", description: "Usuario con atribuciones de atención en su local"}, {name: "Usuario Registrado", description: "Usuario con cuenta registrada y accesible"}, {name: "Usuario No Registrado", description: "Usuario con cuenta no registrada"}])

super_admin = User.create(first_name: 'Sebastián', last_name: 'Hevia', email: 'shevia@agendapro.cl', phone: '+56 9 9477 5641', role: Role.find_by_name('Super Admin'), password: '12345678', password_confirmation: '12345678')

admin = User.create(first_name: 'Nicolás', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '+56 9 9719 8689', role: Role.find_by_name('Admin'), password: '12345678', password_confirmation: '12345678')

user = User.create(first_name: 'Nicolás', last_name: 'Rossi', email: 'nrossi@agendapro.cl', phone: '+56 9 8289 7145', role: Role.find_by_name('Usuario Registrado'), password: '12345678', password_confirmation: '12345678')

company = Company.create(name: 'Test Company', web_address: 'test', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

# Compañías en app anterior

orion = Company.create(name: 'ORION STYLE', web_address: 'orionstyle', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


mandarina = Company.create(name: 'Mandarina', web_address: 'mandarina', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


silviapodologiaclinica = Company.create(name: 'Silvia Podologia Clinica', web_address: 'silviapodologiaclinica', economic_sector_id: 6, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


donosura = Company.create(name: 'Donosura Salón', web_address: 'donosurasalon', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


lucy = Company.create(name: 'Lucy', web_address: 'lucy', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


la_cesta = Company.create(name: 'La Cesta', web_address: 'lacesta', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

cambio_dos = Company.create(name: 'Cambio Dos', web_address: 'mabarrera', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

benestetica = Company.create(name: 'Benestetica', web_address: 'benestetica', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


proterapias = Company.create(name: 'Proterapias', web_address: 'proterapias', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


ps_natalia_campos = Company.create(name: 'Ps Natalia Campos', web_address: 'psnataliacampos', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")


chely = Company.create(name: 'Salón de Belleza Chely', web_address: 'chely', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

#################### Fin de empresas en Beta

service_categories = ServiceCategory.create([{name: "Cortes", company_id: 1}, {name: "Tinturas", company_id: 1}, {name: "Masajes", company_id: 1}])

locals = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

location_times = LocationTime.create([{open: '09:00', close: '18:30', location_id: 1, day_id: 1}, {open: '09:00', close: '18:30', location_id: 1, day_id: 2}, {open: '09:00', close: '18:30', location_id: 1, day_id: 3}, {open: '09:00', close: '18:30', location_id: 1, day_id: 4}, {open: '09:00', close: '18:30', location_id: 1, day_id: 5}])

service_provider = ServiceProvider.create(location_id: 1, user_id: 1, company_id: 1)

service = Service.create([{name: "Corte de pelo", price: 5500, duration: 30, company_id: 1, service_category_id: 1}, {name: "Visos", price: 12000, duration: 45, company_id: 1, service_category_id: 1}])

Service.find(1).tags << Tag.find(1)
Service.find(2).tags << Tag.find(2)


service_provider.services << service

provider_times = ProviderTime.create([{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 1}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 2}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 3}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 4}, {open: '9:00', close: '18:00', service_provider_id: 1, day_id: 5}])

bookings = Booking.create([{start: '2014-1-6T08:30z', end: '2014-1-6T09:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-7T13:30z', end: '2014-1-7T14:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-8T015:00z', end: '2014-1-8T15:30z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-9T16:30z', end: '2014-1-9T17:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-10T09:30z', end: '2014-1-10T10:15z', service_provider_id: 1, user_id: 1, service_id: 2, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}])

dictionaries = Dictionary.create([{name: 'Peluqueria', tag_id: 1}, {name: 'Peluquero', tag_id: 1}, {name: 'Peluquera', tag_id: 1}, {name: 'Salon', tag_id: 1}, {name: 'Salon de Belleza', tag_id: 1}, {name: 'Lavado', tag_id: 1}])