# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Status de las Reservas
reservado = Status.create(name: "Reservado", description: "Reserva asignada")
bloqueado = Status.create(name: "Bloqueado", description: "Hora no disponible bloqueada porel local")
completado = Status.create(name: "Completado", description: "Reserva sólo ha sido agendada")
pagado = Status.create(name: "Pagado", description: "Cliente pre-pago la cita")
cancelado = Status.create(name: "Cancelado", description: "Reserva sólo ha sido agendada")
no_asiste = Status.create(name: "No Asiste", description: "Cliente no llego a la cita")

# Forma de pago de las Empresas
webpay = TransactionType.create(name: "Webpay", description: "El usuario paga por Webpay")
transferencia = TransactionType.create(name: "Transferencia", description: "El usuario paga por trasferencia bancaria")

# Estado de Pago de las Empresas
al_dia = PaymentStatus.create(name: "Al día", description: "La empresa tiene todos los pagos al día")
prueba = PaymentStatus.create(name: "Período de Prueba", description: "La empresa está en período de prueba")
atrasada = PaymentStatus.create(name: "Atrasada", description: "La empresa está atrasada en el pago del mes en curso")
bloqueada = PaymentStatus.create(name: "Bloqueada", description: "La empresa está bloqueada por no pago del plan")

# Sectores Eonómicos de las Empresas
estetica = EconomicSector.create(name: "Centros de Estética")
med_alt = EconomicSector.create(name: "Medicina Alternativa")
sicologia = EconomicSector.create(name: "Sicología")
dentistas = EconomicSector.create(name: "Odontología")
mecanicos = EconomicSector.create(name: "Talleres Mecánicos")
podologia = EconomicSector.create(name: "Centros de Podología")
artes_mariales = EconomicSector.create(name: "Artes Marciales")
yoga = EconomicSector.create(name: "Centros de Yoga")
centros_deportivos = EconomicSector.create(name: "Centros Deportivos")

# Tags para la búsqueda
tags = Tag.create([{name: "Corte de Pelo", economic_sector_id: 1}, {name: "Tinturas", economic_sector_id: 1}, {name: "Masajes", economic_sector_id: 1}, {name: "Tratamientos Especiales", economic_sector_id: 2}])

# Países Activos
countries = Country.create(name: "Chile")

# Regiones de los países activos 
regions = Region.create(name: "Metropolitana", country: countries)

# Ciudades Activas 
cities = City.create(name: "Santiago", region: regions)

# Comunas Activas 
las_condes = District.create(name: "Las Condes", city: cities)
providencia = District.create(name: "Providencia", city: cities)
vitacura = District.create(name: "Vitacura", city: cities)
nunoa = District.create(name: "Ñuñoa", city: cities)
santiago = District.create(name: "Santiago", city: cities)
lo_barnechea = District.create(name: "Lo Barnechea", city: cities)
la_florida = District.create(name: "La Florida", city: cities)
la_reina = District.create(name: "La Reina", city: cities)

days = Day.create([{name: "Lunes"}, {name: "Martes"}, {name: "Miércoles"}, {name: "Jueves"}, {name: "Viernes"}, {name: "Sábado"}, {name: "Domingo"}])

# Planes Disponibles
plan_personal = Plan.create(name: "Personal", locations: 1, service_providers: 1, custom: false, price: 14900, special: false)
plan_basico = Plan.create(name: "Básico", locations: 1, service_providers: 30, custom: false, price: 24900, special: false)
plan_normal = Plan.create(name: "Normal", locations: 2, service_providers: 60, custom: false, price: 39900, special: false)
plan_premium = Plan.create(name: "Premium", locations: 3, service_providers: 90, custom: false, price: 49900, special: false)

# Plan para las personas que partieron con nosotros antes en la Beta y no se han querido cambiar...
plan_beta = Plan.create(name: "Beta", locations: 1, service_providers: 2, custom: true, price: 14900, special: false)

# Roles de la Aplicación 
# POR DEFINIR CAMBIOS EN UN POSIBLE RECEPCIONISTA - ARREGLAR
roles = Role.create([{name: "Super Admin", description: "Administrador de la aplicaión AgendaPro"}, {name: "Admin", description: "Administrador de empresa inscrita en AgendaPro"}, {name: "Administrador Local", description: "Administrador de local"}, {name: "Staff", description: "Usuario con atribuciones de atención en su local"}, {name: "Usuario Registrado", description: "Usuario con cuenta registrada y accesible"}, {name: "Recepción", description: "Usuario con atribuciones de atención para todos los proveedores en su local"}])

super_admin = User.create(first_name: 'Sebastián', last_name: 'Hevia', email: 'shevia@agendapro.cl', phone: '+56 9 9477 5641', role: Role.find_by_name('Super Admin'), password: '12345678', password_confirmation: '12345678')

admin = User.create(first_name: 'Nicolás', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '+56 9 9719 8689', role: Role.find_by_name('Admin'), password: '12345678', password_confirmation: '12345678')

user = User.create(first_name: 'Nicolás', last_name: 'Rossi', email: 'nrossi@agendapro.cl', phone: '+56 9 8289 7145', role: Role.find_by_name('Usuario Registrado'), password: '12345678', password_confirmation: '12345678')

dictionaries = Dictionary.create([{name: 'Peluqueria', tag_id: 1}, {name: 'Peluquero', tag_id: 1}, {name: 'Peluquera', tag_id: 1}, {name: 'Salon', tag_id: 1}, {name: 'Salon de Belleza', tag_id: 1}, {name: 'Lavado', tag_id: 1}])


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

# Servicios de las empresas inscritas en Beta

ser_orion_1 = Service.create(name: "Corte Dama", price: 9500, duration: 30, company_id: orion.id, description: "Incluye: Lavado y secado de cabello")

ser_mandarina_1 = Service.create(name: "Lavado mas brushing pelo corto", price: 8900, duration: 30, company_id: mandarina.id, description: "Lavado con productos redken, loreal, diapo, mas brushing (blow dry)")

ser_mandarina_2 = Service.create{name: "Corte", price: 15000, duration: 30, company_id: mandarina.id, description:"corte incluye lavado y secado"}

ser_mandarina_3 = Service.create{name: "Coloracion Shades EQ REDKEN", price: 29000, duration: 60, company_id: mandarina.id, description:"<p>Color SIN AMONIACO &nbsp;cuida tu cabello, aporte de vitaminas y mucho brillo</p>"}

ser_mandarina_4 = Service.create{name: "Color", price: 25000, duration: 60, company_id: mandarina.id, description:"<p>Retoque raiz de color, para cabellos con mas de 45% de canas.</p>"}

ser_mandarina_5 = Service.create{name: "lavado mas brushing pelo largo", price: 10900, duration: 30, company_id: mandarina.id, description:"<p>lavado mas peinado&nbsp;</p>"}

ser_mandarina_6 = Service.create{name: "lavado mas brushing pelo XL", price: 12900, duration: 60, company_id: mandarina.id, description:"<p>Lavado y brushing para cabellos extra largos</p>"}

ser_mandarina_7 = Service.create{name: "Mechas-Visos-Reflejos", price: 35000, duration: 60, company_id: mandarina.id, description:"<p>Realizamos mechitas con papel, o visos con gorra, y tambien Reflejos.</p><p>Todos los productos utilizados calidad Loreal y Redken.</p><p>Servicio incluye lavado y secado</p>"}

ser_mandarina_8 = Service.create{name: "Mechas Californianas o FreeStyle", price: 45000, duration: 60, company_id: mandarina.id, description:"<p>DESDE 45.000 &nbsp;Servicio Mechas californianas</p>"}

ser_mandarina_9 = Service.create{name: "Tratamiento Reparación profunda CHEMISTRY REDKEN", price: 25000, duration: 45, company_id: mandarina.id, description:"<p>Servicio Reparacion Profunda! Dale nueva vida a tu cabello con este sistema innovador de REDKEN</p>"}

ser_mandarina_10 = Service.create{name: "Aplicacion Ampollas PRO KERATINA", price: 15000, duration: 30, company_id: mandarina.id, description:"<p>Servicio incluye lavado y secado</p>"}

ser_mandarina_11 = Service.create{name: "Tratamiento reparación y brillo REDKEN", price: 15000, duration: 30, company_id: mandarina.id, description:"<p>Dale un Shock de Brillo a tu cabello</p>"}

ser_mandarina_12 = Service.create{name: "ALISADO KERATINA", price: 25000, duration: 60, company_id: mandarina.id, description:"<p>ALISADO KERATINA desde 25.000 depende de tu largo</p><p>recuerda Lunes y Martes 25% descuento en este Servicio!!</p>"}

ser_mandarina_13 = Service.create{name: "BRONCEADO ST TROPEZ", price: 19900, duration: 30, company_id: mandarina.id, description:"<p>BRONCEADO CUERPO COMPLETO CON EL MEJOR PRODUCTO DELICADO!!!!, COLOR NATURAL, NO ZANAHORIA, NI AMARILLO.</p>"}

ser_mandarina_14 = Service.create{name: "MAQUILLAJE NOCHE", price: 25000, duration: 30, company_id: mandarina.id, description:"<p>MAQUILLAJE QUE DURA TODA LA NOCHE!</p>"}

ser_mandarina_15 = Service.create{name: "MAQUILLAJE DIA", price: 17900, duration: 30, company_id: mandarina.id, description:"<p>MAQUILLAJE PARA EL DIA</p>"}

ser_silvia_1 = Service.create{name: "Podologia", price: 10000, duration: 45, company_id: silviapodologiaclinica.id, description:"<p>Pie diabetico</p><p>Tratamientos</p><p>Micosis</p><p>&nbsp;</p>"}

ser_silvia_2 = Service.create{name: "Onicocriptosis (uñas encarnadas)", price: 17000, duration: 30, company_id: silviapodologiaclinica.id, description:"<p>Solo se trata el dedo afectado</p>"}

ser_silvia_3 = Service.create{name: "Depilacion brazileña", price: 15000, duration: 30, company_id: silviapodologiaclinica.id, description:"<p>depilacion total</p>"}

ser_silvia_4 = Service.create{name: "manicure", price: 6000, duration: 30, company_id: silviapodologiaclinica.id, description:"<p>Opi</p><p>Sparitual</p>"}

ser_silvia_5 = Service.create{name: "Masaje corporal 1 hora", price: 18000, duration: 60, company_id: silviapodologiaclinica.id, description:"<p>masaje con aceites naturales (melisa, chocolate, romero, canela y lavanda)</p>"}

ser_silvia_6 = Service.create{name: "masaje corporal 30 min", price: 9000, duration: 30, company_id: silviapodologiaclinica.id, description:"<p>masaje con aceites naturales (lavanda, canela, melisa y chocolate)</p>"}

ser_silvia_7 = Service.create{name: "masoterapia 20 min", price: 6000, duration: 20, company_id: silviapodologiaclinica.id, description:"<p>masaje relajante para pies con aceites naturales</p>"}

ser_silvia_8= Service.create{name: "Reflexologia", price: 14000, duration: 45, company_id: silviapodologiaclinica.id, description:"<p>logra un equilibrio energetico del cuerpo atravez de estimulos en los pies.</p><p>Obteniendo un beneficio sobre las partes del cuerpo que lo necesiten&nbsp;</p>"}

ser_silvia_9= Service.create{name: "Reiki", price: 20000, duration: 60, company_id: silviapodologiaclinica.id, description:"<p>sanacion energetica</p><p>limpieza del chacra</p><p>sacar cordones</p>"}

ser_donosura_1= Service.create{name: "Corte Dama", price: 18000, duration: 30, company_id: donosura.id, description:"<p>Corte con tijera</p>"}

ser_donosura_2= Service.create{name: "Lavado con crema", price: 3000, duration: 15, company_id: donosura.id, description:""}

ser_donosura_3= Service.create{name: "Lavado con ampolla", price: 5000, duration: 15, company_id: donosura.id, description:""}

ser_donosura_4= Service.create{name: "Brushing pelo corto", price: 6000, duration: 30, company_id: donosura.id, description:""}

ser_donosura_5= Service.create{name: "Brushing pelo medio", price: 8000, duration: 30, company_id: donosura.id, description:""}

ser_donosura_6= Service.create{name: "Brushing pelo largo", price: 10000, duration: 30, company_id: donosura.id, description:""}

ser_donosura_7= Service.create{name: "Peinado simple", price: 12000, duration: 30, company_id: donosura.id, description:""

ser_donosura_8= Service.create{name: "Peinado elaborado", price: 18000, duration: 45, company_id: donosura.id, description:""}

ser_donosura_9= Service.create{name: "Corte varón", price: 8000, duration: 30, company_id: donosura.id, description:""}

ser_donosura_10= Service.create{name: "Tintura normal", price: 25000, duration: 15, company_id: donosura.id, description:""}

ser_donosura_11= Service.create{name: "Tintura raíz a punta", price: 35000, duration: 15, company_id: donosura.id, description:"<p>Productos:</p><p>Bella</p><p>Alfaparf</p><p>Loreal</p><p>BBCos</p><p><strong><span style=\"color: #666699;\">Color con micro pigmentaci&oacute;n&nbsp;</span></strong></p>"}

ser_donosura_12= Service.create{name: "Mechas saltadas", price: 25000, duration: 15, company_id: donosura.id, description:"<p>Productos: blondor</p><p>Azulado sin polvo en suspensi&oacute;n&nbsp;</p>"}

ser_donosura_13= Service.create{name: "Visos con papel", price: 35000, duration: 30, company_id: donosura.id, description:"<p>Productos: blondor Bella y Alparf</p>"}

ser_donosura_14= Service.create{name: "Tintura californiana en degrade", price: 45000, duration: 45, company_id: donosura.id, description:""}

ser_donosura_15= Service.create{name: "Reflejos", price: 35000, duration: 15, company_id: donosura.id, description:"<p>Sin decolorante, color directo.</p>"}

ser_donosura_16= Service.create{name: "Ondulación basé normal horizontal", price: 20000, duration: 60, company_id: donosura.id, description:"<p>Tratamiento ondulatorio para pelo corto</p><p>Fijador y neutralizante&nbsp;</p>"}

ser_donosura_17= Service.create{name: "Ondulación vertical", price: 30000, duration: 60, company_id: donosura.id, description:"<p>Tratamiento ondulatorio pelo largo</p><p>fijador y neutralizante Lakme y Loreal</p>"}

ser_donosura_18= Service.create{name: "Alisado de Keratina pelo normal ", price: 50000, duration: 60, company_id: donosura.id, description:""}

ser_donosura_19= Service.create{name: "Alisado de Keratina pelo largo", price: 70000, duration: 60, company_id: donosura.id, description:"<p>Brasil cacao de Oil Argan</p><p>tratamiento anti volumen Inoa</p>"}

ser_donosura_20= Service.create{name: "Tratamiento hidratante Keratina ", price: 35000, duration: 45, company_id: donosura.id, description:"<p>Producto:</p><p>sebastian</p>"}

ser_donosura_21= Service.create{name: "Tratamiento termo sellante", price: 25000, duration: 30, company_id: donosura.id, description:"<p>Producto:</p><p>sebastian penetraitt&nbsp;</p>"}

ser_donosura_22= Service.create{name: "Masaje capilar ", price: 18000, duration: 15, company_id: donosura.id, description:"<p>Tratamiento con vaporizador&nbsp;</p><p>crema Sebasti&aacute;n penetraitt</p>"}

ser_donosura_23= Service.create{name: "Maquillaje rostro para fiesta ", price: 18000, duration: 45, company_id: donosura.id, description:""}

ser_donosura_24= Service.create{name: "Manicure", price: 7000, duration: 30, company_id: donosura.id, description:"<p>Limado--limpieza--esmaltado.</p>"}

ser_donosura_25= Service.create{name: "Pedicure", price: 9000, duration: 30, company_id: donosura.id, description:"<p>Limado--limpieza---esmaltado.</p>"}

ser_donosura_26= Service.create{name: "Podologia", price: 12000, duration: 45, company_id: donosura.id, description:"<p>&nbsp;Retiro de durezas--limpieza profunda--limado--esmaltado.</p>"}

ser_donosura_27= Service.create{name: "Esmaltado permanente", price: 18000, duration: 45, company_id: donosura.id, description:"<p>Limado--limpieza--esmaltado.</p>"}

ser_donosura_28= Service.create{name: "Ondulado de  pestañas permanente con tinte ", price: 18000, duration: 60, company_id: donosura.id, description:"<p>Ondular--fijar--te&ntilde;ir</p>"}

ser_donosura_29= Service.create{name: "Masaje descontracturante", price: 20000, duration: 60, company_id: donosura.id, description:"<p>Ubicar contractura---drenar.</p>"}

ser_donosura_30= Service.create{name: "Masaje relajante", price: 18000, duration: 60, company_id: donosura.id, description:"<p>Relajar hombros y extremidades</p>"}

ser_donosura_31= Service.create{name: "Masaje reductivo con ultracavitacion - 10 sesiones", price: 260000, duration: 60, company_id: donosura.id, description:"<p>Eliminar la grasa localizada--drenar--moldear</p>"}

ser_donosura_32= Service.create{name: "Masaje reductivo manual. Incluye maderoterapia. 10 sesiones", price: 180000, duration: 60, company_id: donosura.id, description:"<p>drenar-- moldear-- trabajar celulitis .</p>"}

ser_donosura_33= Service.create{name: "Manicure express", price: 4000, duration: 15, company_id: donosura.id, description:"<p>Limado--esmaltado</p>"}


ser_proterapias_1= Service.create{name: "APITERAPIA", price: 10000, duration: 30, company_id: proterapias.id, description:"<p>Tratamiento de enfermedades y dolencias con veneno de abejas.</p>"}

ser_proterapias_2= Service.create{name: "REIKI CHAMANICO ", price: 15000, duration: 60, company_id: proterapias.id, description:"<p>Terapia de canalizaci&oacute;n de energ&iacute;a a trav&eacute;s de la imposici&oacute;n de manos.</p>"}

ser_proterapias_3= Service.create{name: "REFLEXOLOGIA", price: 15000, duration: 60, company_id: proterapias.id, description:"<p>Terapia china que se realiza en los pies, mediante t&eacute;cnicas de estimulaci&oacute;n y relajaci&oacute;n en las distintas zonas reflejas.</p>"}

ser_proterapias_4= Service.create{name: "BIOMAGNETISMO", price: 15000, duration: 60, company_id: proterapias.id, description:"<p>A trav&eacute;s de Imanes, se equilibra el Ph del cuerpo, anulando la existencia de cualquier agente patogeno, se elimina VIRUS BACTERIAS PAR&Aacute;SITOS Y HONGOS.</p><p>Puedes tratar cualquier enfermedad</p>"}

ser_proterapias_5= Service.create{name: "REIKI USUI", price: 15000, duration: 60, company_id: proterapias.id, description:"<p>Traspaso de Energ&iacute;a Universal a trav&eacute;s de la Imposici&oacute;n de Manos, realinea y equilibra los Chacras, alivia malestares tanto fisicos, emocionales y psicologicos</p>"}

ser_proterapias_6= Service.create{name: "E.F.T. Técnicas de Liberación Emocional", price: 15000, duration: 60, company_id: proterapias.id, description:"<p>T&eacute;nica basada en DigitoPuntura y Programaci&oacute;n Neuroling&uuml;istica, que elimina cualquier Emoci&oacute;n atrapada como Duelos, reparaciones, traumas, fobias, Baja Autoestima, Adicciones, etc.</p>"}

ser_proterapias_7= Service.create{name: "MASAJE CRANEAL HINDÚ ", price: 15000, duration: 30, company_id: proterapias.id, description:"<p>Se centra en la parte superior de la Espalda Hombros, Cuello, Craneo y Rostro. El masaje se da sentado sin la necesidad de desnudar a la persona, Alivia migra&ntilde;as, estados depresivos, bruxismo, y lo complementamos con Reiki.</p>"}

ser_psnatalia_1= Service.create{name: "Consulta psicológica ", price: 20000, duration: 45, company_id: ps_natalia_campos.id, description:"<p>Psic&oacute;loga Cl&iacute;nica acreditada. Magister en Psicolog&iacute;a Clinica con formaci&oacute;n en terapia familiar, de pareja e individual. Diplomado en Sexualidad. Flores de Bach.</p>"}

ser_chely_1= Service.create{name: "Tintura ", price: 21900, duration: 60, company_id: chely.id, description:"<p>Tintura Majirel de L&acute;oreal. Tinturas cortas 60 minutos, tinturas largas una hora y media.</p>"}

kathy = User.create(first_name: 'Kathy', last_name: 'Valdes', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'agendapro', password_confirmation: 'agendapro')

#gabriel = User.create(first_name: 'Gabriel', last_name: 'Morales', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

#silvio = User.create(first_name: 'Silvio', last_name: 'Yapura', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

#miriam = User.create(first_name: 'Miriam', last_name: 'Concha', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

#vicky = User.create(first_name: 'Vicky', last_name: 'Cancino', email: 'mandarinabeauty@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'agendapro', password_confirmation: 'agendapro')

silvia = User.create(first_name: 'Silvia', last_name: 'Sepúlveda', email: 'silviagatitagat@hotmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'perlita', password_confirmation: 'perlita')

guillermo = User.create(first_name: 'José Guillermo', last_name: 'Donoso Palma', email: 'donosura.guillermo@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'peluqueria', password_confirmation: 'peluqueria')

#aida = User.create(first_name: 'aida', last_name: 'sepulveda', email: 'aidy_sep@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'cachito', password_confirmation: 'cachito')

# admin = User.create(first_name: 'silvia', last_name: 'sepulveda', email: 'silviagatitagat@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: '', password_confirmation: '')

lucia = User.create(first_name: 'Lucía', last_name: 'Albarracin', email: 'albarracinl@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'lucy2014', password_confirmation: 'lucy2014')

juan = User.create(first_name: 'Juan', last_name: 'Sanchez', email: 'frommysofa@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'larrinaga', password_confirmation: 'larrinaga')

maria = User.create(first_name: 'María Amelia', last_name: 'Barrera', email: 'mariamelia.barrera@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'mamelia', password_confirmation: 'mamelia')

pablo = User.create(first_name: 'Pablo', last_name: 'Henriquez', email: 'pabli80@hotmail.it', phone: '', role: Role.find_by_name('Admin'), password: 'amore', password_confirmation: 'amore')

rose = User.create(first_name: 'Rose Mary', last_name: 'Arce', email: 'proterapias@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'provi', password_confirmation: 'provi')

#jose = User.create(first_name: 'José', last_name: 'León', email: 'Josemiel98@yahoo.es', phone: '', role: Role.find_by_name('Staff'), password: '75085153', password_confirmation: '75085153')

natalia = User.create(first_name: 'Natalia', last_name: 'Campos', email: 'nataliacamposv@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'natinati', password_confirmation: 'natinati')

#sandra = User.create(first_name: 'Sandra', last_name: 'Pacheco Luengo', email: 'sandra.p.luengo@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'EFT', password_confirmation: 'EFT')

#carolina = User.create(first_name: 'Carolina', last_name: 'Ulloa', email: 'Moscar_m@hotmail.com', phone: '', role: Role.find_by_name('Staff'), password: '1234', password_confirmation: '1234')

daniella = User.create(first_name: 'Daniella', last_name: 'Leiva', email: 'la.perpetua@gmail.com', phone: '', role: Role.find_by_name('Admin'), password: 'eternos2481', password_confirmation: 'eternos2481')

#monica = User.create(first_name: 'Monica', last_name: 'Pascual', email: 'la.perpetua@gmail.com', phone: '', role: Role.find_by_name('Staff'), password: 'peluqueria', password_confirmation: 'peluqueria')

# Locales Clientes Beta, agregar las latitudes!!!

local_orion = Location.create(name: 'ORION SAN CRESCENTE', address: 'SAN CRESCENTE 94', phone: '02-23340869', district_id: 1, company_id: orion.id, latitude: -33.4129192, longitude: -70.5921359)

local_mandarina = Location.create(name: 'MANDARINA plaza peru', address: 'isidora goyenechea 3051 local 12', phone: '23357964', district_id: 3, company_id: mandarina.id, latitude: -33.4129192, longitude: -70.5921359)

local_silvia = Location.create(name: 'Clinica Podologia Silvia Providencia', address: 'Av Providencia 2594 local 201', phone: '2 2234 3845', district_id: 2, company_id: silviapodologiaclinica.id, latitude: -33.4129192, longitude: -70.5921359)

local_donosura = Location.create(name: 'Donosura salón el golf', address: 'San Sebastián 2881 local 2', phone: '27109443', district_id: 1, company_id: donosura.id, latitude: -33.4129192, longitude: -70.5921359)

local_lucy = Location.create(name: 'Salon lucy', address: 'Providencia 2562 Local 39', phone: '23355330', district_id: 2, company_id: lucy.id, latitude: -33.4129192, longitude: -70.5921359)

# local_la_cesta = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

# local_cambio_dos = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

# local_benestetica = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

local_proterapias = Location.create(name: 'Centro Medicina Natural PROTERAPIAS', address: 'Avda Providencia 1077 of. 202', phone: '62009989', district_id: 2, company_id: proterapias.id, latitude: -33.4129192, longitude: -70.5921359)

local_ps_natalia_campos = Location.create(name: 'Psicología Clínica Natalia Campos', address: 'Simón Bolivar 2183', phone: '+569 9994656', district_id: 4, company_id: ps_natalia_campos.id, latitude: -33.4129192, longitude: -70.5921359)

local_chely = Location.create(name: 'Salón de Belleza Chely', address: 'Explorador Fawcett 1660, local 112, Pueblo del Inglés', phone: '+5622191162', district_id: 3, company_id: chely.id, latitude: -33.4129192, longitude: -70.5921359)

# Horarios de las empresas en Beta

orion_times = LocationTime.create([{open: '10:00', close: '20:00', location_id: local_orion.id, day_id: 1}, {open: '10:00', close: '20:00', location_id: local_orion.id, day_id: 2}, {open: '10:00', close: '20:00', location_id: local_orion.id, day_id: 3}, {open: '10:00', close: '20:00', location_id: local_orion.id, day_id: 4}, {open: '10:00', close: '20:00', location_id: local_orion.id, day_id: 5}])

mandarina_times = LocationTime.create([{open: '10:00', close: '21:00', location_id: local_mandarina.id, day_id: 1}, {open: '10:00', close: '21:00', location_id: local_mandarina.id, day_id: 2}, {open: '10:00', close: '21:00', location_id: local_mandarina.id, day_id: 3}, {open: '10:00', close: '21:00', location_id: local_mandarina.id, day_id: 4}, {open: '10:00', close: '21:00', location_id: local_mandarina.id, day_id: 5}])

silvia_times = LocationTime.create([{open: '10:00', close: '20:00', location_id: local_silvia.id, day_id: 1}, {open: '10:00', close: '20:00', location_id: local_silvia.id, day_id: 2}, {open: '10:00', close: '20:00', location_id: local_silvia.id, day_id: 3}, {open: '10:00', close: '20:00', location_id: local_silvia.id, day_id: 4}, {open: '10:00', close: '20:00', location_id: local_silvia.id, day_id: 5}])

donosura_times = LocationTime.create([{open: '10:00', close: '19:00', location_id: local_donosura.id, day_id: 2}, {open: '10:00', close: '19:00', location_id: local_donosura.id, day_id: 3}, {open: '10:00', close: '19:00', location_id: local_donosura.id, day_id: 4}, {open: '10:00', close: '19:00', location_id: local_donosura.id, day_id: 5}, {open: '10:00', close: '15:00', location_id: local_donosura.id, day_id: 6}])

lucy_times = LocationTime.create([{open: '10:00', close: '20:00', location_id: local_donosura.id, day_id: 1}, {open: '10:00', close: '20:00', location_id: local_donosura.id, day_id: 2}, {open: '10:00', close: '20:00', location_id: local_donosura.id, day_id: 3}, {open: '10:00', close: '20:00', location_id: local_donosura.id, day_id: 4}, {open: '10:00', close: '20:00', location_id: local_donosura.id, day_id: 5}, {open: '10:00', close: '14:00', location_id: local_donosura.id, day_id: 6}])

proterapias_times = LocationTime.create([{open: '09:00', close: '19:00', location_id: local_proterapias.id, day_id: 1}, {open: '09:00', close: '19:00', location_id: local_proterapias.id, day_id: 2}, {open: '09:00', close: '19:00', location_id: local_proterapias.id, day_id: 3}, {open: '09:00', close: '19:00', location_id: local_proterapias.id, day_id: 4}, {open: '09:00', close: '19:00', location_id: local_proterapias.id, day_id: 5}, {open: '09:00', close: '14:00', location_id: local_proterapias.id, day_id: 6}])

ps_natalia_campos_times = LocationTime.create([{open: '17:00', close: '20:00', location_id: local_ps_natalia_campos.id, day_id: 1}, {open: '12:00', close: '13:00', location_id: local_ps_natalia_campos.id, day_id: 2}, {open: '12:00', close: '13:00', location_id: local_ps_natalia_campos.id, day_id: 3}, {open: '09:00', close: '11:00', location_id: local_ps_natalia_campos.id, day_id: 4}])

chely_times = LocationTime.create([{open: '09:00', close: '18:00', location_id: local_chely.id, day_id: 1}, {open: '09:00', close: '18:00', location_id: local_chely.id, day_id: 2}, {open: '09:00', close: '18:00', location_id: local_chely.id, day_id: 3}, {open: '09:00', close: '18:00', location_id: local_chely.id, day_id: 4}, {open: '09:00', close: '18:00', location_id: local_chely.id, day_id: 5}, {open: '09:00', close: '14:00', location_id: local_chely.id, day_id: 6}])

# Service Provider de cada uno de los clientes en Beta - COMPLETAR

gm = ServiceProvider.create(location_id: local_mandarina.id, company_id: mandarina.id, notification_email: 'mandarinabeauty@gmail.com', public_name: 'Gabriel Morales')

gm_times = ProviderTime.create([
	{open: '10:00', close: '21:00', service_provider_id: gm.id, day_id: 1}, 
	{open: '10:00', close: '21:00', service_provider_id: gm.id, day_id: 2}, 
	{open: '10:00', close: '21:00', service_provider_id: gm.id, day_id: 3}, 
	{open: '10:00', close: '21:00', service_provider_id: gm.id, day_id: 4}, 
	{open: '10:00', close: '21:00', service_provider_id: gm.id, day_id: 5},
	{open: '10:00', close: '18:00', service_provider_id: gm.id, day_id: 6}])

sy = ServiceProvider.create(location_id: local_mandarina.id, company_id: mandarina.id, notification_email: 'mandarinabeauty@gmail.com', public_name: 'Silvio Yapura')

sy_times = ProviderTime.create([
	{open: '10:00', close: '21:00', service_provider_id: sy.id, day_id: 1}, 
	{open: '10:00', close: '21:00', service_provider_id: sy.id, day_id: 2}, 
	{open: '10:00', close: '21:00', service_provider_id: sy.id, day_id: 3}, 
	{open: '10:00', close: '21:00', service_provider_id: sy.id, day_id: 4}, 
	{open: '10:00', close: '21:00', service_provider_id: sy.id, day_id: 5},
	{open: '10:00', close: '18:00', service_provider_id: sy.id, day_id: 6}])

mc = ServiceProvider.create(location_id: local_mandarina.id, company_id: mandarina.id, notification_email: 'mandarinabeauty@gmail.com', public_name: 'Miriam Concha')

mc_times = ProviderTime.create([
	{open: '10:00', close: '21:00', service_provider_id: mc.id, day_id: 1}, 
	{open: '10:00', close: '21:00', service_provider_id: mc.id, day_id: 2}, 
	{open: '10:00', close: '21:00', service_provider_id: mc.id, day_id: 3}, 
	{open: '10:00', close: '21:00', service_provider_id: mc.id, day_id: 4}, 
	{open: '10:00', close: '21:00', service_provider_id: mc.id, day_id: 5},
	{open: '10:00', close: '18:00', service_provider_id: mc.id, day_id: 6}])

vc = ServiceProvider.create(location_id: local_mandarina.id, company_id: mandarina.id, notification_email: 'mandarinabeauty@gmail.com', public_name: 'Vicky Cancino')

vc_times = ProviderTime.create([
	{open: '10:00', close: '21:00', service_provider_id: vc.id, day_id: 1}, 
	{open: '10:00', close: '21:00', service_provider_id: vc.id, day_id: 2}, 
	{open: '10:00', close: '21:00', service_provider_id: vc.id, day_id: 3}, 
	{open: '10:00', close: '21:00', service_provider_id: vc.id, day_id: 4}, 
	{open: '10:00', close: '21:00', service_provider_id: vc.id, day_id: 5,}
	{open: '10:00', close: '18:00', service_provider_id: vc.id, day_id: 6}])

kv = ServiceProvider.create(location_id: local_mandarina.id, company_id: mandarina.id, notification_email: 'mandarinabeauty@gmail.com', public_name: 'Kathy Valdes')

kv_times = ProviderTime.create([
	{open: '10:00', close: '21:00', service_provider_id: ky.id, day_id: 1}, 
	{open: '10:00', close: '21:00', service_provider_id: ky.id, day_id: 2}, 
	{open: '10:00', close: '21:00', service_provider_id: ky.id, day_id: 3}, 
	{open: '10:00', close: '21:00', service_provider_id: ky.id, day_id: 4}, 
	{open: '10:00', close: '21:00', service_provider_id: ky.id, day_id: 5},
	{open: '10:00', close: '18:00', service_provider_id: ky.id, day_id: 6}])

as = ServiceProvider.create(location_id: local_silvia.id, company_id: silviapodologiaclinica.id, notification_email: 'aidy_sep@hotmail.com', public_name: 'Aida Sepulveda')

as_times = ProviderTime.create([
	{open: '10:00', close: '20:00', service_provider_id: as.id, day_id: 1}, 
	{open: '10:00', close: '20:00', service_provider_id: as.id, day_id: 2}, 
	{open: '10:00', close: '20:00', service_provider_id: as.id, day_id: 3}, 
	{open: '10:00', close: '20:00', service_provider_id: as.id, day_id: 4}, 
	{open: '10:00', close: '20:00', service_provider_id: as.id, day_id: 5}
	{open: '10:00', close: '14:00', service_provider_id: as.id, day_id: 6}])

ss = ServiceProvider.create(location_id: local_silvia.id, company_id: silviapodologiaclinica.id, notification_email: 'silviagatitagat@hotmail.com', public_name: 'Silvia Sepulveda')

ss_times = ProviderTime.create([
	{open: '10:00', close: '19:00', service_provider_id: ss.id, day_id: 1}, 
	{open: '10:00', close: '19:00', service_provider_id: ss.id, day_id: 2}, 
	{open: '10:00', close: '19:00', service_provider_id: ss.id, day_id: 3}, 
	{open: '10:00', close: '19:00', service_provider_id: ss.id, day_id: 4}, 
	{open: '10:00', close: '19:00', service_provider_id: ss.id, day_id: 5},
	{open: '10:00', close: '14:00', service_provider_id: ss.id, day_id: 6}])

gd = ServiceProvider.create(location_id: local_donosura.id, company_id: donosura.id, notification_email: 'guillermo.donosura@gmail.com', public_name: 'Guillermo Donoso')

gd_times = ProviderTime.create([ 
	{open: '10:00', close: '20:00', service_provider_id: gd.id, day_id: 2}, 
	{open: '10:00', close: '20:00', service_provider_id: gd.id, day_id: 3}, 
	{open: '10:00', close: '20:00', service_provider_id: gd.id, day_id: 4}, 
	{open: '10:00', close: '20:00', service_provider_id: gd.id, day_id: 5},
	{open: '10:00', close: '15:00', service_provider_id: gd.id, day_id: 6}])

jl = ServiceProvider.create(location_id: local_donosura.id, company_id: donosura.id, notification_email: 'josemiel98@yahoo.es', public_name: 'José León')

jl_times = ProviderTime.create([
	{open: '10:00', close: '19:00', service_provider_id: jl.id, day_id: 2}, 
	{open: '10:00', close: '19:00', service_provider_id: jl.id, day_id: 3}, 
	{open: '10:00', close: '19:00', service_provider_id: jl.id, day_id: 4}, 
	{open: '10:00', close: '19:00', service_provider_id: jl.id, day_id: 5},
	{open: '10:00', close: '15:00', service_provider_id: jl.id, day_id: 6}])

ng = ServiceProvider.create(location_id: local_donosura.id, company_id: donosura.id, notification_email: 'guillermo.donosura@gmail.com', public_name: 'Nancy Gomez')

ng_times = ProviderTime.create([ 
	{open: '10:00', close: '19:00', service_provider_id: ng.id, day_id: 2}, 
	{open: '10:00', close: '19:00', service_provider_id: ng.id, day_id: 3}, 
	{open: '10:00', close: '19:00', service_provider_id: ng.id, day_id: 4}, 
	{open: '10:00', close: '19:00', service_provider_id: ng.id, day_id: 5},
	{open: '10:00', close: '15:00', service_provider_id: ng.id, day_id: 6}])

sp = ServiceProvider.create(location_id: local_proterapias.id, company_id: proterapias.id, notification_email: 'sandra.p.luengo@gmail.com', public_name: 'Sandra Pacheco')

sp_times = ProviderTime.create([
	{open: '10:00', close: '19:00', service_provider_id: sp.id, day_id: 1}, 
	{open: '10:00', close: '19:00', service_provider_id: sp.id, day_id: 2}, 
	{open: '10:00', close: '19:00', service_provider_id: sp.id, day_id: 3}, 
	{open: '10:00', close: '19:00', service_provider_id: sp.id, day_id: 4}, 
	{open: '10:00', close: '19:00', service_provider_id: sp.id, day_id: 5},
	{open: '10:00', close: '14:00', service_provider_id: sp.id, day_id: 6}])

rm = ServiceProvider.create(location_id: local_proterapias.id, company_id: proterapias.id, notification_email: 'rosmary.rc@gmail.com', public_name: 'Rose Mary')

rm_times = ProviderTime.create([
	{open: '10:00', close: '19:00', service_provider_id: rm.id, day_id: 1}, 
	{open: '10:00', close: '19:00', service_provider_id: rm.id, day_id: 2}, 
	{open: '10:00', close: '19:00', service_provider_id: rm.id, day_id: 3}, 
	{open: '10:00', close: '19:00', service_provider_id: rm.id, day_id: 4}, 
	{open: '10:00', close: '19:00', service_provider_id: rm.id, day_id: 5},
	{open: '10:00', close: '14:00', service_provider_id: rm.id, day_id: 6}])

nc = ServiceProvider.create(location_id: local_ps_natalia_campos.id, company_id: ps_natalia_campos.id, notification_email: 'nataliacamposv@gmail.com', public_name: 'Natalia Campos')

nc_times = ProviderTime.create([
	{open: '10:00', close: '19:00', service_provider_id: nc.id, day_id: 1}, 
	{open: '12:00', close: '13:00', service_provider_id: nc.id, day_id: 2}, 
	{open: '12:00', close: '13:00', service_provider_id: nc.id, day_id: 3}, 
	{open: '09:00', close: '11:00', service_provider_id: nc.id, day_id: 4}])

mp = ServiceProvider.create(location_id: local_chely.id, company_id: chely.id, notification_email: 'la.perpetua@gmail.com', public_name: 'Monica Pascual')

mp_times = ProviderTime.create([
	{open: '09:00', close: '18:00', service_provider_id: mp.id, day_id: 1}, 
	{open: '09:00', close: '18:00', service_provider_id: mp.id, day_id: 3}, 
	{open: '09:00', close: '18:00', service_provider_id: mp.id, day_id: 4}, 
	{open: '09:00', close: '18:00', service_provider_id: mp.id, day_id: 5},
	{open: '09:00', close: '14:00', service_provider_id: mp.id, day_id: 6}])

# Asignación de servicios a cada uno de los proveedores de los clientes en BETA

gm.services << ser_mandarina_1
gm.services << ser_mandarina_2
gm.services << ser_mandarina_3
gm.services << ser_mandarina_4
gm.services << ser_mandarina_5
gm.services << ser_mandarina_6
gm.services << ser_mandarina_7
gm.services << ser_mandarina_8
gm.services << ser_mandarina_9
gm.services << ser_mandarina_10
gm.services << ser_mandarina_11
gm.services << ser_mandarina_12
sy.services << ser_mandarina_1
sy.services << ser_mandarina_2
sy.services << ser_mandarina_3
sy.services << ser_mandarina_4
sy.services << ser_mandarina_5
sy.services << ser_mandarina_6
sy.services << ser_mandarina_7
sy.services << ser_mandarina_8
sy.services << ser_mandarina_9
sy.services << ser_mandarina_10
sy.services << ser_mandarina_11
sy.services << ser_mandarina_12
sy.services << ser_mandarina_14
sy.services << ser_mandarina_15
mc.services << ser_mandarina_1
mc.services << ser_mandarina_2
mc.services << ser_mandarina_3
mc.services << ser_mandarina_4
mc.services << ser_mandarina_5
mc.services << ser_mandarina_6
mc.services << ser_mandarina_7
mc.services << ser_mandarina_8
mc.services << ser_mandarina_9
mc.services << ser_mandarina_10
mc.services << ser_mandarina_11
mc.services << ser_mandarina_12
vc.services << ser_mandarina_1
vc.services << ser_mandarina_2
vc.services << ser_mandarina_3
vc.services << ser_mandarina_4
vc.services << ser_mandarina_5
vc.services << ser_mandarina_6
vc.services << ser_mandarina_7
vc.services << ser_mandarina_8
vc.services << ser_mandarina_9
vc.services << ser_mandarina_10
vc.services << ser_mandarina_11
vc.services << ser_mandarina_12
kv.services << ser_mandarina_13
as.services << ser_silvia_1
as.services << ser_silvia_2
as.services << ser_silvia_3
as.services << ser_silvia_4
as.services << ser_silvia_7
ss.services << ser_silvia_1
ss.services << ser_silvia_2
ss.services << ser_silvia_3
ss.services << ser_silvia_4
ss.services << ser_silvia_5
ss.services << ser_silvia_6
ss.services << ser_silvia_7
ss.services << ser_silvia_8
ss.services << ser_silvia_9
gd.services << ser_donosura_1
gd.services << ser_donosura_2
gd.services << ser_donosura_3
gd.services << ser_donosura_4
gd.services << ser_donosura_5
gd.services << ser_donosura_6
gd.services << ser_donosura_7
gd.services << ser_donosura_8
gd.services << ser_donosura_9
gd.services << ser_donosura_10
gd.services << ser_donosura_11
gd.services << ser_donosura_12
gd.services << ser_donosura_13
gd.services << ser_donosura_14
gd.services << ser_donosura_15
gd.services << ser_donosura_16
gd.services << ser_donosura_17
gd.services << ser_donosura_18
gd.services << ser_donosura_19
gd.services << ser_donosura_20
gd.services << ser_donosura_21
gd.services << ser_donosura_22
jl.services << ser_donosura_1
jl.services << ser_donosura_2
jl.services << ser_donosura_3
jl.services << ser_donosura_4
jl.services << ser_donosura_5
jl.services << ser_donosura_6
jl.services << ser_donosura_7
jl.services << ser_donosura_8
jl.services << ser_donosura_9
jl.services << ser_donosura_10
jl.services << ser_donosura_11
jl.services << ser_donosura_12
jl.services << ser_donosura_13
jl.services << ser_donosura_14
jl.services << ser_donosura_15
jl.services << ser_donosura_16
jl.services << ser_donosura_17
jl.services << ser_donosura_18
jl.services << ser_donosura_19
jl.services << ser_donosura_20
jl.services << ser_donosura_21
jl.services << ser_donosura_22
ng.services << ser_donosura_23
ng.services << ser_donosura_24
ng.services << ser_donosura_25
ng.services << ser_donosura_26
ng.services << ser_donosura_27
ng.services << ser_donosura_28
ng.services << ser_donosura_29
ng.services << ser_donosura_30
ng.services << ser_donosura_31
ng.services << ser_donosura_32
ng.services << ser_donosura_33
sp.services << ser_proterapias_4
sp.services << ser_proterapias_5
sp.services << ser_proterapias_6
sp.services << ser_proterapias_7
rm.services << ser_proterapias_1
rm.services << ser_proterapias_2
rm.services << ser_proterapias_3
nc.services << ser_psnatalia_1
mp.services << ser_chely_1


# BOOKINGS DE LOS CLIENTES EN BETA

bookings_beta = Booking.create([
{start: '2014-1-28T11:00z', end: '2014-1-28T11:30z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Sonia', last_name: 'Ojeda', email: 'pijmsrr@yahoo.com', phone: '23264421'},
{start: '2014-1-29T17:00z', end: '2014-1-29T17:30z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Karla', last_name: 'Berndt', email: 'kberndt@camatal.cl', phone: '23358364-092927996'},
{start: '2014-1-30T11:00z', end: '2014-1-30T11:30z', service_provider_id: gd.id, service_id: ser_donosura_4.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Angelica', last_name: 'Fernandez', email: 'mafernandez@apa.cl', phone: '94358687'},
{start: '2014-1-29T18:00z', end: '2014-1-29T18:30z', service_provider_id: gd.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Diego', last_name: 'Carracedo', email: 'dcarracedo@ingenierosdelcobre.cl', phone: '88092383'},
{start: '2014-1-30T19:00z', end: '2014-1-30T19:30z', service_provider_id: gd.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'eduward', last_name: 'Andersen', email: 'eandersen@rexel.cl', phone: '68488297'},
{start: '2014-1-31T13:00z', end: '2014-1-31T13:30z', service_provider_id: gd.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Ignacio', last_name: 'Rodriguez', email: 'Ignacio.rodriguez@celebrate.cl', phone: '92768115'},
{start: '2014-1-28T10:15z', end: '2014-1-28T10:30z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Valentina', last_name: 'Perez', email: 'valentina.perez@sodexo.com', phone: '98294450'},
{start: '2014-1-28T19:00z', end: '2014-1-28T19:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: cancelado.id, first_name: 'Maria', last_name: 'Angelica', email: 'a-mackines@hotmail.com', phone: '98223723'},
{start: '2014-2-1T10:00z', end: '2014-2-1T10:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Maria Angelica', last_name: 'mackines', email: 'a-mackines@hotmail.com', phone: '98223723'},
{start: '2014-1-30T17:00z', end: '2014-1-30T17:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Cecilia', last_name: 'Tutera', email: 'ceciliatutera@hotmail.com', phone: '22086855'},
{start: '2014-1-29T17:45z', end: '2014-1-29T18:00z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Paola', last_name: 'gonzalez quesada', email: 'paolagonzalezq@gmail.com', phone: '76927288'},
{start: '2014-1-30T16:15z', end: '2014-1-30T16:30z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Ely', last_name: 'Moreira', email: 'lucortinas@hotmail.com', phone: '83413590'},
{start: '2014-1-31T11:00z', end: '2014-1-31T11:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Mabel', last_name: 'Gomez', email: 'dgomez@bancoripley.cl', phone: '91617789'},
{start: '2014-2-1T12:00z', end: '2014-2-1T12:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Lorena', last_name: 'Brito', email: 'lorenabritom@yahoo.com', phone: '28858193'},
{start: '2014-1-31T15:00z', end: '2014-1-31T15:15z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Leonor', last_name: 'Velasquez', email: 'leonorvd@hotmail.com', phone: '73776832'},
{start: '2014-1-31T17:30z', end: '2014-1-31T17:45z', service_provider_id: gd.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Maria Elena', last_name: 'Moreno', email: 'memoreno@watts.cl', phone: '24414249'},
{start: '2014-2-1T10:15z', end: '2014-2-1T11:30z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Ana Maria', last_name: 'Castro Gonzales', email: 'acastroden@hotmail.com', phone: '98265952'},
{start: '2014-1-31T16:45z', end: '2014-1-31T15:00z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Kenia Maria de los angeles', last_name: 'Bravo Hurtado', email: 'kbravo@enap.cl', phone: '88896841'},
{start: '2014-2-1T11:45z', end: '2014-2-1T12:00z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Cecilia', last_name: 'recabarren', email: 'donosura.guillermo@gmail.com', phone: '96828004'},
{start: '2014-2-1T10:15z', end: '2014-1-28T10:30z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Anita', last_name: 'Castro', email: 'acastrodent@hotmail.com', phone: '98265952'},
{start: '2014-2-1T14:00z', end: '2014-2-1T14:15z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Beatriz', last_name: 'Palau Ruiz', email: 'bpalau@cosas.com', phone: '98261791'},
{start: '2014-2-1T13:00z', end: '2014-2-1T13:15z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Susan', last_name: 'Ross', email: 'susrossa@gmail.com', phone: '54019641'},
{start: '2014-1-28T10:30z', end: '2014-1-28T11:00z', service_provider_id: gd.id, service_id: ser_donosura_13.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Josee', last_name: 'abourbih', email: 'joseeabourbih@gmail.com', phone: '98217618'},
{start: '2014-1-29T11:00z', end: '2014-1-29T11:30z', service_provider_id: gd.id, service_id: ser_donosura_13.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Macarena', last_name: 'Espinoza', email: 'maccaritoo@hotmail.com', phone: '98194292'},
{start: '2014-2-1T10:30z', end: '2014-2-1T11:00z', service_provider_id: gd.id, service_id: ser_donosura_13.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Rocio', last_name: 'Carrasco', email: 'rciocarrascoa@gmail.com', phone: '61490935'},
{start: '2014-2-1T14:30z', end: '2014-2-1T15:00z', service_provider_id: gd.id, service_id: ser_donosura_13.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Macarena', last_name: 'Ramirez', email: 'makarena.ramirez.g@gmail.com', phone: '94141214'},
{start: '2014-2-3T12:00z', end: '2014-2-3T12:15z', service_provider_id: gd.id, service_id: ser_donosura_15.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Adryana', last_name: 'Serrano', email: 'adryanaserranoa@hotmail.com', phone: '91684074'},
{start: '2014-2-1T11:00z', end: '2014-2-1T11:15z', service_provider_id: gd.id, service_id: ser_donosura_15.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Barbara', last_name: 'Ibarra Muñoz', email: 'barbara.ibarramz@gmail.com', phone: '77655615'},
{start: '2014-1-31T18:00z', end: '2014-1-31T18:15z', service_provider_id: gd.id, service_id: ser_donosura_15.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Lorena', last_name: 'Fernandez', email: 'mlorenafernandez@fuenzalida.com', phone: '98224488'},
{start: '2014-2-1T12:30z', end: '2014-2-1T12:45z', service_provider_id: gd.id, service_id: ser_donosura_15.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Alejandra', last_name: 'Cortes Inzunza', email: 'acortes@consultoresinzunza.cl', phone: '66992780'},
{start: '2014-1-28T12:00z', end: '2014-1-28T13:00z', service_provider_id: gd.id, service_id: ser_donosura_18.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Evelyn', last_name: 'Bravo', email: 'evelynbrav@gmail.com', phone: '98712059'},
{start: '2014-1-30T10:00z', end: '2014-1-30T11:00z', service_provider_id: gd.id, service_id: ser_donosura_19.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Denisse', last_name: 'Pizarro', email: 'denisse-f@hotmail.cl', phone: '82109215'},
{start: '2014-1-30T18:00z', end: '2014-1-30T18:30z', service_provider_id: gd.id, service_id: ser_donosura_21.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Violeta', last_name: 'meersohn', email: 'vmershon@hotmail.com', phone: '92195749'},
{start: '2014-1-31T17:00z', end: '2014-1-31T17:30z', service_provider_id: jl.id, service_id: ser_donosura_4.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Sara', last_name: 'Alemania', email: 'josemiel98@yahoo.es', phone: '95619067'},
{start: '2014-1-31T16:00z', end: '2014-1-31T16:30z', service_provider_id: jl.id, service_id: ser_donosura_4.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Patricia', last_name: 'doren loys', email: 'Patricia.Doren@sura.cl', phone: '852926774'},
{start: '2014-1-31T14:30z', end: '2014-1-31T15:00z', service_provider_id: jl.id, service_id: ser_donosura_5.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Isabel', last_name: 'Rico', email: 'isabelrico@invove.com', phone: '609777602'},
{start: '2014-1-29T15:00z', end: '2014-1-29T15:30z', service_provider_id: jl.id, service_id: ser_donosura_5.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Sandra', last_name: 'Ulloa', email: 'sandra.ulloa.u@gmail.com', phone: '81392218'},
{start: '2014-1-31T10:00z', end: '2014-1-31T10:30z', service_provider_id: jl.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Jean Carlo', last_name: 'garniani', email: 'josemiel98@yahoo.es', phone: '95619067'},
{start: '2014-1-31T13:00z', end: '2014-1-31T13:30z', service_provider_id: jl.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Pablo', last_name: 'Gomez', email: 'josemiel98@yahoo.es', phone: '95619067'},
{start: '2014-1-31T18:00z', end: '2014-1-31T18:30z', service_provider_id: jl.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Juan Pablo', last_name: 'Leon', email: 'josemiel98@yahoo.es', phone: '95619067'},
{start: '2014-2-1T12:00z', end: '2014-2-1T12:30z', service_provider_id: jl.id, service_id: ser_donosura_9.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Diego', last_name: 'prieto santander', email: 'dprietosantander@gmail.com', phone: '91073366'},
{start: '2014-1-31T14:30z', end: '2014-1-31T15:00z', service_provider_id: jl.id, service_id: ser_donosura_10.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Mabel', last_name: 'Gomez', email: 'dgomez@bancoripley.cl', phone: '91617789'},
{start: '2014-1-29T18:15z', end: '2014-1-29T19:00z', service_provider_id: ng.id, service_id: ser_donosura_26.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Margarita', last_name: 'Barrios', email: 'margarita.barrios@zurich.com', phone: '79678439'},
{start: '2014-1-30T15:15z', end: '2014-1-30T16:00z', service_provider_id: ng.id, service_id: ser_donosura_26.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Ana Maria', last_name: 'Blanco', email: 'anblanco@larrainvial.com', phone: '23398617'},
{start: '2014-2-1T10:00z', end: '2014-2-1T10:45z', service_provider_id: ng.id, service_id: ser_donosura_26.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Ana Maria', last_name: 'Castro Gonzalez', email: 'acastroden@hotmail.com', phone: '98265952'},
{start: '2014-1-30T17:00z', end: '2014-1-30T18:00z', service_provider_id: ng.id, service_id: ser_donosura_29.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Lua', last_name: 'Moreira', email: 'lua@live.cl', phone: '76161728'},
{start: '2014-1-31T16:00z', end: '2014-1-31T17:00z', service_provider_id: ng.id, service_id: ser_donosura_29.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Dominick', last_name: 'Bonilla', email: 'doboma@gmail.com', phone: '83603091'},
{start: '2014-1-31T10:00z', end: '2014-1-31T11:00z', service_provider_id: ng.id, service_id: ser_donosura_31.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Sonia', last_name: 'Triana', email: 'soniatriana@me.com', phone: '71078180'},
{start: '2014-1-30T18:00z', end: '2014-1-30T19:00z', service_provider_id: ng.id, service_id: ser_donosura_31.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Violena', last_name: 'meersohn', email: 'vmeersohn@hotmail.com', phone: '92195749'},
{start: '2014-1-28T14:00z', end: '2014-1-28T15:00z', service_provider_id: ng.id, service_id: ser_donosura_32.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Jessica', last_name: 'Perez', email: 'jessica.pekus@gmail.com', phone: '78890277'},
{start: '2014-1-31T15:00z', end: '2014-1-31T116:00z', service_provider_id: ng.id, service_id: ser_donosura_32.id, location_id: local_donosura.id, status_id: reservado.id, first_name: 'Catalina', last_name: 'Huertas', email: 'catahuertas@gmail.com', phone: '65390746'}])

#################### Fin de empresas en Beta