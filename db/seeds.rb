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
economic_sectors = EconomicSector.create(name: "Centros de Podología")

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

orion = Company.create(name: 'ORION STYLE', web_address: 'orionstyle', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

mandarina = Company.create(name: 'Mandarina', web_address: 'mandarina', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

silviapodologiaclinica = Company.create(name: 'Silvia Podologia Clinica', web_address: 'silviapodologiaclinica', economic_sector_id: 6, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

donosura = Company.create(name: 'Donosura Salón', web_address: 'donosurasalon', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

lucy = Company.create(name: 'Lucy', web_address: 'lucy', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

la_cesta = Company.create(name: 'La Cesta', web_address: 'lacesta', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

cambio_dos = Company.create(name: 'Cambio Dos', web_address: 'mabarrera', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

benestetica = Company.create(name: 'Benestetica', web_address: 'benestetica', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

proterapias = Company.create(name: 'Proterapias', web_address: 'proterapias', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

ps_natalia_campos = Company.create(name: 'Ps Natalia Campos', web_address: 'psnataliacampos', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

chely = Company.create(name: 'Salón de Belleza Chely', web_address: 'chely', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "", cancellation_policy: "")

# Locales Clientes Beta, agregar las latitudes!!!

local_orion = Location.create(name: 'ORION SAN CRESCENTE', address: 'SAN CRESCENTE 94', phone: '02-23340869', district_id: 1, company_id: 2, latitude: -33.4129192, longitude: -70.5921359)

local_mandarina = Location.create(name: 'MANDARINA plaza peru', address: 'isidora goyenechea 3051 local 12', phone: '23357964', district_id: 3, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

local_silvia = Location.create(name: 'Clinica Podologia Silvia Providencia', address: 'Av Providencia 2594 local 201', phone: '2 2234 3845', district_id: 2, company_id: 4, latitude: -33.4129192, longitude: -70.5921359)

local_donosura = Location.create(name: 'Donosura salón el golf', address: 'San Sebastián 2881 local 2', phone: '27109443', district_id: 1, company_id: 5, latitude: -33.4129192, longitude: -70.5921359)

local_lucy = Location.create(name: 'Salon lucy', address: 'Providencia 2562 Local 39', phone: '23355330', district_id: 2, company_id: 6, latitude: -33.4129192, longitude: -70.5921359)

# local_la_cesta = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

# local_cambio_dos = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

# local_benestetica = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

local_proterapias = Location.create(name: 'Centro Medicina Natural PROTERAPIAS', address: 'Avda Providencia 1077 of. 202', phone: '62009989', district_id: 2, company_id: 10, latitude: -33.4129192, longitude: -70.5921359)

local_ps_natalia_campos = Location.create(name: 'Psicología Clínica Natalia Campos', address: 'Simón Bolivar 2183', phone: '+569 9994656', district_id: 4, company_id: 11, latitude: -33.4129192, longitude: -70.5921359)

local_chely = Location.create(name: 'Salón de Belleza Chely', address: 'Explorador Fawcett 1660, local 112, Pueblo del Inglés', phone: '+5622191162', district_id: 3, company_id: 12, latitude: -33.4129192, longitude: -70.5921359)

# Servicios de las empresas inscritas en Beta

service = Service.create([
	{name: "Corte Dama", price: 9500, duration: 30, company_id: 2, description: "Incluye: Lavado y secado de cabello"},
	{name: "Lavado mas brushing pelo corto", price: 8900, duration: 30, company_id: 3, description: "Lavado con productos redken, loreal, diapo, mas brushing (blow dry)"},
	{name: "Corte", price: 15000, duration: 30, company_id: 3, description:"corte incluye lavado y secado"},
	{name: "Coloracion Shades EQ REDKEN", price: 29000, duration: 60, company_id: 3, description:"<p>Color SIN AMONIACO &nbsp;cuida tu cabello, aporte de vitaminas y mucho brillo</p>"},
	{name: "Color", price: 25000, duration: 60, company_id: 3, description:"<p>Retoque raiz de color, para cabellos con mas de 45% de canas.</p>"},
	{name: "lavado mas brushing pelo largo", price: 10900, duration: 30, company_id: 3, description:"<p>lavado mas peinado&nbsp;</p>"},
	{name: "lavado mas brushing pelo XL", price: 12900, duration: 60, company_id: 3, description:"<p>Lavado y brushing para cabellos extra largos</p>"},
	{name: "Mechas-Visos-Reflejos", price: 35000, duration: 60, company_id: 3, description:"<p>Realizamos mechitas con papel, o visos con gorra, y tambien Reflejos.</p><p>Todos los productos utilizados calidad Loreal y Redken.</p><p>Servicio incluye lavado y secado</p>"},
	{name: "Mechas Californianas o FreeStyle", price: 45000, duration: 60, company_id: 3, description:"<p>DESDE 45.000 &nbsp;Servicio Mechas californianas</p>"},
	{name: "Tratamiento Reparación profunda CHEMISTRY REDKEN", price: 25000, duration: 45, company_id: 3, description:"<p>Servicio Reparacion Profunda! Dale nueva vida a tu cabello con este sistema innovador de REDKEN</p>"},
	{name: "Aplicacion Ampollas PRO KERATINA", price: 15000, duration: 30, company_id: 3, description:"<p>Servicio incluye lavado y secado</p>"},
	{name: "Tratamiento reparación y brillo REDKEN", price: 15000, duration: 30, company_id: 3, description:"<p>Dale un Shock de Brillo a tu cabello</p>"},
	{name: "ALISADO KERATINA", price: 25000, duration: 60, company_id: 3, description:"<p>ALISADO KERATINA desde 25.000 depende de tu largo</p><p>recuerda Lunes y Martes 25% descuento en este Servicio!!</p>"},
	{name: "BRONCEADO ST TROPEZ", price: 19900, duration: 30, company_id: 3, description:"<p>BRONCEADO CUERPO COMPLETO CON EL MEJOR PRODUCTO DELICADO!!!!, COLOR NATURAL, NO ZANAHORIA, NI AMARILLO.</p>"},
	{name: "MAQUILLAJE NOCHE", price: 25000, duration: 30, company_id: 3, description:"<p>MAQUILLAJE QUE DURA TODA LA NOCHE!</p>"},
	{name: "MAQUILLAJE DIA", price: 17900, duration: 30, company_id: 3, description:"<p>MAQUILLAJE PARA EL DIA</p>"},
	{name: "Corte Dama", price: 18000, duration: 30, company_id: 5, description:"<p>Corte con tijera</p>"},
	{name: "Podologia", price: 10000, duration: 45, company_id: 4, description:"<p>Pie diabetico</p><p>Tratamientos</p><p>Micosis</p><p>&nbsp;</p>"},
	{name: "Onicocriptosis (uñas encarnadas)", price: 17000, duration: 30, company_id: 4, description:"<p>Solo se trata el dedo afectado</p>"},
	{name: "Depilacion brazileña", price: 15000, duration: 30, company_id: 4, description:"<p>depilacion total</p>"},
	{name: "manicure", price: 6000, duration: 30, company_id: 4, description:"<p>Opi</p><p>Sparitual</p>"},
	{name: "Masaje corporal 1 hora", price: 18000, duration: 60, company_id: 4, description:"<p>masaje con aceites naturales (melisa, chocolate, romero, canela y lavanda)</p>"},
	{name: "masaje corporal 30 min", price: 9000, duration: 30, company_id: 4, description:"<p>masaje con aceites naturales (lavanda, canela, melisa y chocolate)</p>"},
	{name: "masoterapia 20 min", price: 6000, duration: 20, company_id: 4, description:"<p>masaje relajante para pies con aceites naturales</p>"},
	{name: "Reflexologia", price: 14000, duration: 45, company_id: 4, description:"<p>logra un equilibrio energetico del cuerpo atravez de estimulos en los pies.</p><p>Obteniendo un beneficio sobre las partes del cuerpo que lo necesiten&nbsp;</p>"},
	{name: "Reiki", price: 20000, duration: 60, company_id: 4, description:"<p>sanacion energetica</p><p>limpieza del chacra</p><p>sacar cordones</p>"},
	{name: "Lavado con crema", price: 3000, duration: 15, company_id: 5, description:""},
	{name: "Lavado con ampolla", price: 5000, duration: 15, company_id: 5, description:""},
	{name: "Brushing pelo corto", price: 6000, duration: 30, company_id: 5, description:""},
	{name: "Brushing pelo medio", price: 8000, duration: 30, company_id: 5, description:""},
	{name: "Brushing pelo largo", price: 10000, duration: 30, company_id: 5, description:""},
	{name: "Peinado simple", price: 12000, duration: 30, company_id: 5, description:""},
	{name: "Peinado elaborado", price: 18000, duration: 45, company_id: 5, description:""},
	{name: "Corte varón", price: 8000, duration: 30, company_id: 5, description:""},
	{name: "Tintura normal", price: 25000, duration: 15, company_id: 5, description:""},
	{name: "Tintura raíz a punta", price: 35000, duration: 15, company_id: 5, description:"<p>Productos:</p><p>Bella</p><p>Alfaparf</p><p>Loreal</p><p>BBCos</p><p><strong><span style=\"color: #666699;\">Color con micro pigmentaci&oacute;n&nbsp;</span></strong></p>"},
	{name: "Mechas saltadas", price: 25000, duration: 15, company_id: 5, description:"<p>Productos: blondor</p><p>Azulado sin polvo en suspensi&oacute;n&nbsp;</p>"},
	{name: "Visos con papel", price: 35000, duration: 30, company_id: 5, description:"<p>Productos: blondor Bella y Alparf</p>"},
	{name: "Tintura californiana en degrade", price: 45000, duration: 45, company_id: 5, description:""},
	{name: "Reflejos", price: 35000, duration: 15, company_id: 5, description:"<p>Sin decolorante, color directo.</p>"},
	{name: "Ondulación basé normal horizontal", price: 20000, duration: 60, company_id: 5, description:"<p>Tratamiento ondulatorio para pelo corto</p><p>Fijador y neutralizante&nbsp;</p>"},
	{name: "Ondulación vertical", price: 30000, duration: 60, company_id: 5, description:"<p>Tratamiento ondulatorio pelo largo</p><p>fijador y neutralizante Lakme y Loreal</p>"},
	{name: "Alisado de Keratina pelo normal ", price: 50000, duration: 60, company_id: 5, description:""},
	{name: "Alisado de Keratina pelo largo", price: 70000, duration: 60, company_id: 5, description:"<p>Brasil cacao de Oil Argan</p><p>tratamiento anti volumen Inoa</p>"},
	{name: "Tratamiento hidratante Keratina ", price: 35000, duration: 45, company_id: 5, description:"<p>Producto:</p><p>sebastian</p>"},
	{name: "Tratamiento termo sellante", price: 25000, duration: 30, company_id: 5, description:"<p>Producto:</p><p>sebastian penetraitt&nbsp;</p>"},
	{name: "Masaje capilar ", price: 18000, duration: 15, company_id: 5, description:"<p>Tratamiento con vaporizador&nbsp;</p><p>crema Sebasti&aacute;n penetraitt</p>"},
	{name: "Maquillaje rostro para fiesta ", price: 18000, duration: 45, company_id: 5, description:""},
	{name: "Consulta psicológica ", price: 20000, duration: 45, company_id: 11, description:"<p>Psic&oacute;loga Cl&iacute;nica acreditada. Magister en Psicolog&iacute;a Clinica con formaci&oacute;n en terapia familiar, de pareja e individual. Diplomado en Sexualidad. Flores de Bach.</p>"},
	{name: "APITERAPIA", price: 10000, duration: 30, company_id: 10, description:"<p>Tratamiento de enfermedades y dolencias con veneno de abejas.</p>"},
	{name: "REIKI CHAMANICO ", price: 15000, duration: 60, company_id: 10, description:"<p>Terapia de canalizaci&oacute;n de energ&iacute;a a trav&eacute;s de la imposici&oacute;n de manos.</p>"},
	{name: "REFLEXOLOGIA", price: 15000, duration: 60, company_id: 10, description:"<p>Terapia china que se realiza en los pies, mediante t&eacute;cnicas de estimulaci&oacute;n y relajaci&oacute;n en las distintas zonas reflejas.</p>"},
	{name: "Manicure", price: 7000, duration: 30, company_id: 5, description:"<p>Limado--limpieza--esmaltado.</p>"},
	{name: "Pedicure", price: 9000, duration: 30, company_id: 5, description:"<p>Limado--limpieza---esmaltado.</p>"},
	{name: "Podologia", price: 12000, duration: 45, company_id: 5, description:"<p>&nbsp;Retiro de durezas--limpieza profunda--limado--esmaltado.</p>"},
	{name: "Esmaltado permanente", price: 18000, duration: 45, company_id: 5, description:"<p>Limado--limpieza--esmaltado.</p>"},
	{name: "Ondulado de  pestañas permanente con tinte ", price: 18000, duration: 60, company_id: 5, description:"<p>Ondular--fijar--te&ntilde;ir</p>"},
	{name: "Masaje descontracturante", price: 20000, duration: 60, company_id: 5, description:"<p>Ubicar contractura---drenar.</p>"},
	{name: "Masaje relajante", price: 18000, duration: 60, company_id: 5, description:"<p>Relajar hombros y extremidades</p>"},
	{name: "Masaje reductivo con ultracavitacion - 10 sesiones", price: 260000, duration: 60, company_id: 5, description:"<p>Eliminar la grasa localizada--drenar--moldear</p>"},
	{name: "Masaje reductivo manual. Incluye maderoterapia. 10 sesiones", price: 180000, duration: 60, company_id: 5, description:"<p>drenar-- moldear-- trabajar celulitis .</p>"},
	{name: "Manicure express", price: 4000, duration: 15, company_id: 5, description:"<p>Limado--esmaltado</p>"},
	{name: "BIOMAGNETISMO", price: 15000, duration: 60, company_id: 10, description:"<p>A trav&eacute;s de Imanes, se equilibra el Ph del cuerpo, anulando la existencia de cualquier agente patogeno, se elimina VIRUS BACTERIAS PAR&Aacute;SITOS Y HONGOS.</p><p>Puedes tratar cualquier enfermedad</p>"},
	{name: "REIKI USUI", price: 15000, duration: 60, company_id: 10, description:"<p>Traspaso de Energ&iacute;a Universal a trav&eacute;s de la Imposici&oacute;n de Manos, realinea y equilibra los Chacras, alivia malestares tanto fisicos, emocionales y psicologicos</p>"},
	{name: "E.F.T. Técnicas de Liberación Emocional", price: 15000, duration: 60, company_id: 10, description:"<p>T&eacute;nica basada en DigitoPuntura y Programaci&oacute;n Neuroling&uuml;istica, que elimina cualquier Emoci&oacute;n atrapada como Duelos, reparaciones, traumas, fobias, Baja Autoestima, Adicciones, etc.</p>"},
	{name: "MASAJE CRANEAL HINDÚ ", price: 15000, duration: 30, company_id: 10, description:"<p>Se centra en la parte superior de la Espalda Hombros, Cuello, Craneo y Rostro. El masaje se da sentado sin la necesidad de desnudar a la persona, Alivia migra&ntilde;as, estados depresivos, bruxismo, y lo complementamos con Reiki.</p>"}, 
	{name: "Tintura ", price: 21900, duration: 60, company_id: 12, description:"<p>Tintura Majirel de L&acute;oreal. Tinturas cortas 60 minutos, tinturas largas una hora y media.</p>"}])

mandarina_admin = User.create(first_name: 'Kathy', last_name: 'Valdes', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'agendapro', password_confirmation: 'agendapro')

mandarina_staff = User.create(first_name: 'Gabriel', last_name: 'Morales', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

mandarina_staff2 = User.create(first_name: 'Silvio', last_name: 'Yapura', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

mandarina_staff3 = User.create(first_name: 'Miriam', last_name: 'Concha', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

mandarina_staff4 = User.create(first_name: 'Vicky', last_name: 'Cancino', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

admin = User.create(first_name: 'Silvia', last_name: 'Sepúlveda', email: 'silviagatitagat@hotmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'perlita', password_confirmation: 'perlita')

donosura_admin = User.create(first_name: 'José Guillermo', last_name: 'Donoso Palma', email: 'donosura.guillermo@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'peluqueria', password_confirmation: 'peluqueria')

admin = User.create(first_name: 'aida', last_name: 'sepulveda', email: 'aidy_sep@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'cachito', password_confirmation: 'cachito')

admin = User.create(first_name: 'silvia', last_name: 'sepulveda', email: 'silviagatitagat@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: '', password_confirmation: '')

admin = User.create(first_name: 'Lucía', last_name: 'Albarracin', email: 'albarracinl@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'lucy2014', password_confirmation: 'lucy2014')

admin = User.create(first_name: 'Juan', last_name: 'Sanchez', email: 'frommysofa@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'larrinaga', password_confirmation: 'larrinaga')

admin = User.create(first_name: 'María Amelia', last_name: 'Barrera', email: 'mariamelia.barrera@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'mamelia', password_confirmation: 'mamelia')

admin = User.create(first_name: 'Pablo', last_name: 'Henriquez', email: 'pabli80@hotmail.it', phone: '', role: Role.find_by_name('Admin'), password: 'amore', password_confirmation: 'amore')

admin = User.create(first_name: 'Rose Mary', last_name: 'Arce', email: 'proterapias@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'provi', password_confirmation: 'provi')

admin = User.create(first_name: 'José', last_name: 'León', email: 'Josemiel98@yahoo.es', phone: '', role: Role.find_by_name('Staff'), password: '75085153', password_confirmation: '75085153')

admin = User.create(first_name: 'Natalia', last_name: 'Campos', email: 'nataliacamposv@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'natinati', password_confirmation: 'natinati')

admin = User.create(first_name: 'Sandra', last_name: 'Pacheco Luengo', email: 'sandra.p.luengo@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'EFT', password_confirmation: 'EFT')

admin = User.create(first_name: 'Carolina', last_name: 'Ulloa', email: 'Moscar_m@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: '1234', password_confirmation: '1234')

admin = User.create(first_name: 'Daniella', last_name: 'Leiva', email: 'la.perpetua@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'eternos2481', password_confirmation: 'eternos2481')

admin = User.create(first_name: 'Monica', last_name: 'Pascual', email: 'la.perpetua@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'peluqueria', password_confirmation: 'peluqueria')

#################### Fin de empresas en Beta

service_categories = ServiceCategory.create([{name: "Cortes", company_id: 1}, {name: "Tinturas", company_id: 1}, {name: "Masajes", company_id: 1}])

locals = Location.create([{name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359},
	{name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359}])

location_times = LocationTime.create([{open: '09:00', close: '18:30', location_id: 1, day_id: 1}, {open: '09:00', close: '18:30', location_id: 1, day_id: 2}, {open: '09:00', close: '18:30', location_id: 1, day_id: 3}, {open: '09:00', close: '18:30', location_id: 1, day_id: 4}, {open: '09:00', close: '18:30', location_id: 1, day_id: 5}])

service_provider = ServiceProvider.create(location_id: 1, user_id: 1, company_id: 1, notification_email: 'contacto@agendapro.cl', public_name: 'Provider Test')

service = Service.create([{name: "Corte de pelo", price: 5500, duration: 30, company_id: 1, service_category_id: 1}, {name: "Visos", price: 12000, duration: 45, company_id: 1, service_category_id: 1}])

Service.find(1).tags << Tag.find(1)
Service.find(2).tags << Tag.find(2)


service_provider.services << service

provider_times = ProviderTime.create([{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 1}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 2}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 3}, {open: '09:00', close: '18:00', service_provider_id: 1, day_id: 4}, {open: '9:00', close: '18:00', service_provider_id: 1, day_id: 5}])

bookings = Booking.create([{start: '2014-1-6T08:30z', end: '2014-1-6T09:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-7T13:30z', end: '2014-1-7T14:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-8T015:00z', end: '2014-1-8T15:30z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-9T16:30z', end: '2014-1-9T17:00z', service_provider_id: 1, user_id: 1, service_id: 1, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}, {start: '2014-1-10T09:30z', end: '2014-1-10T10:15z', service_provider_id: 1, user_id: 1, service_id: 2, location_id: 1, status_id: 1, first_name: 'Nicolas', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '95482649'}])

dictionaries = Dictionary.create([{name: 'Peluqueria', tag_id: 1}, {name: 'Peluquero', tag_id: 1}, {name: 'Peluquera', tag_id: 1}, {name: 'Salon', tag_id: 1}, {name: 'Salon de Belleza', tag_id: 1}, {name: 'Lavado', tag_id: 1}])