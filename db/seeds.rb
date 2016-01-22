# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
# #
# # Examples:
# #
# #   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
# #   Mayor.create(name: 'Emanuel', city: cities.first)

# # => Roles de la Aplicación 
# 	roles = Role.create([
# 		{name: "Super Admin", description: "Administrador de la aplicaión AgendaPro"},
# 		{name: "Administrador General", description: "Administrador de empresa inscrita en AgendaPro"},
# 		{name: "Administrador Local", description: "Administrador de local"},
# 		{name: "Staff", description: "Usuario con atribuciones de atención en su local"},
# 		{name: "Staff (sin edición)", description: "Usuario con atribuciones de ver sus reservas"},
# 		{name: "Usuario Registrado", description: "Usuario con cuenta registrada y accesible"},
# 		{name: "Recepcionista", description: "Usuario frontdesk de una empresa"}
# 	])

# 	super_admin = User.create(first_name: 'Sebastián', last_name: 'Hevia', email: 'shevia@agendapro.cl', phone: '+56 9 9477 5641', role: Role.find_by_name('Super Admin'), password: '12345678', password_confirmation: '12345678')

# # => Configuraciones Globales de la Aplicación
# 	iva = NumericParameter.create(name: "sales_tax", value: 0.19)
# 	cuatro_meses = NumericParameter.create(name: "4_month_discount", value: 0.05)
# 	seis_meses = NumericParameter.create(name: "6_month_discount", value: 0.1)
# 	nueve_meses = NumericParameter.create(name: "9_month_discount", value: 0.15)
# 	doce_meses = NumericParameter.create(name: "12_month_discount", value: 0.2)

# # => Dias
# 	days = Day.create([{name: "Lunes"}, {name: "Martes"}, {name: "Miércoles"}, {name: "Jueves"}, {name: "Viernes"}, {name: "Sábado"}, {name: "Domingo"}])

# # => Status de las Reservas
# 	reservado = Status.create(name: "Reservado", description: "Reserva agendada")
# 	bloqueado = Status.create(name: "Confirmado", description: "Reserva confirmada por el Usuario")
# 	asiste = Status.create(name: "Asiste", description: "Reserva completada con el cliente")
# 	cancelado = Status.create(name: "Cancelado", description: "Reserva sólo ha sido agendada")
# 	no_asiste = Status.create(name: "No Asiste", description: "Cliente no llego a la cita")

# # => Forma de pago de las Empresas
# 	webpay = TransactionType.create(name: "Webpay", description: "El usuario paga por Webpay")
# 	transferencia = TransactionType.create(name: "Transferencia", description: "El usuario paga por trasferencia bancaria")

# # => Estado de Pago de las Empresas
# 	activo = PaymentStatus.create(name: "Activo", description: "La empresa tiene todos los pagos al día")
# 	inactivo = PaymentStatus.create(name: "Inactivo", description: "Empresa inactivada por no pago/uso")
# 	emitido = PaymentStatus.create(name: "Emitido", description: "La empresa tiene un pago emitido vigente, aún no vencido")
# 	bloqueado = PaymentStatus.create(name: "Bloqueado", description: "La empresa está bloqueada por no pago del plan")
# 	trial = PaymentStatus.create(name: "Trial", description: "La empresa está en período de prueba")
# 	vencido = PaymentStatus.create(name: "Vencido", description: "La empresa está atrasada en el pago del mes en curso")
# 	vacia = PaymentStatus.create(name: "Admin", description: "Empresa Vacía")

# # => Sectores Eonómicos de las Empresas
# 	estetica = EconomicSector.create(name: "Centros de Estética")
# 	med_alt = EconomicSector.create(name: "Medicina Alternativa")
# 	sicologia = EconomicSector.create(name: "Psicología")
# 	dentistas = EconomicSector.create(name: "Odontología")
# 	mecanicos = EconomicSector.create(name: "Talleres Mecánicos")
# 	podologia = EconomicSector.create(name: "Centros de Podología")
# 	artes_mariales = EconomicSector.create(name: "Artes Marciales")
# 	yoga = EconomicSector.create(name: "Centros de Yoga")
# 	centros_deportivos = EconomicSector.create(name: "Centros Deportivos")
# 	kinesiologia = EconomicSector.create(name: "Kinesiología")
# 	spas = EconomicSector.create(name: "SPA")

# # => Diccionatio Sector Economico
# 	estetica_dic = EconomicSectorsDictionary.create([
# 		{name: 'Estética', economic_sector_id: estetica.id},
# 		{name: 'Estetica', economic_sector_id: estetica.id},
# 		{name: 'Centro de Belleza', economic_sector_id: estetica.id},
# 		{name: 'Beauty Center', economic_sector_id: estetica.id},
# 		{name: 'Peluquería', economic_sector_id: estetica.id},
# 		{name: 'Peluqueria', economic_sector_id: estetica.id},
# 		{name: 'Peluqueros', economic_sector_id: estetica.id},
# 		{name: 'Centro de Estetica', economic_sector_id: estetica.id},
# 		{name: 'Centros de Estetica', economic_sector_id: estetica.id},
# 		{name: 'Centros de Estética', economic_sector_id: estetica.id}
# 	])
# 	dentistas_dic = EconomicSectorsDictionary.create([
# 		{name: 'Dentista', economic_sector_id: dentistas.id},
# 		{name: 'Odontologo', economic_sector_id: dentistas.id},
# 		{name: 'Odontologa', economic_sector_id: dentistas.id},
# 		{name: 'Dientes', economic_sector_id: dentistas.id},
# 		{name: 'Diente', economic_sector_id: dentistas.id}
# 	])
# 	kinesiologia_dic = EconomicSectorsDictionary.create([
# 		{name: 'Kinesiologo', economic_sector_id: kinesiologia.id},
# 		{name: 'Kinesiologa', economic_sector_id: kinesiologia.id},
# 		{name: 'kinesiologia', economic_sector_id: kinesiologia.id},
# 		{name: 'Kinesiologos', economic_sector_id: kinesiologia.id},
# 		{name: 'Kinesiologas', economic_sector_id: kinesiologia.id},
# 		{name: 'Quinesiologia', economic_sector_id: kinesiologia.id},
# 		{name: 'Quinesiologo', economic_sector_id: kinesiologia.id},
# 		{name: 'Quinesiología', economic_sector_id: kinesiologia.id},
# 		{name: 'Quinesiologos', economic_sector_id: kinesiologia.id},
# 		{name: 'Kine', economic_sector_id: kinesiologia.id}
# 	])
# 	sicologia_dic = EconomicSectorsDictionary.create([
# 		{name: 'Sicología', economic_sector_id: sicologia.id},
# 		{name: 'Sicologia', economic_sector_id: sicologia.id},
# 		{name: 'Psicologo', economic_sector_id: sicologia.id},
# 		{name: 'Psicologa', economic_sector_id: sicologia.id},
# 		{name: 'Sicologo', economic_sector_id: sicologia.id},
# 		{name: 'Sicologa', economic_sector_id: sicologia.id},
# 		{name: 'Psicólogo', economic_sector_id: sicologia.id},
# 		{name: 'Psicologia', economic_sector_id: sicologia.id}
# 	])
# 	med_alt_dic = EconomicSectorsDictionary.create([
# 		{name: 'Acupuntura', economic_sector_id: med_alt.id},
# 		{name: 'Reiki', economic_sector_id: med_alt.id},
# 		{name: 'Dieta', economic_sector_id: med_alt.id},
# 		{name: 'Energia', economic_sector_id: med_alt.id}
# 	])
# 	mecanicos_dic = EconomicSectorsDictionary.create([
# 		{name: 'Talleres Mecanicos', economic_sector_id: mecanicos.id},
# 		{name: 'Taller', economic_sector_id: mecanicos.id},
# 		{name: 'Mecanico', economic_sector_id: mecanicos.id},
# 		{name: 'Mecánicos', economic_sector_id: mecanicos.id},
# 		{name: 'Mecánico', economic_sector_id: mecanicos.id},
# 		{name: 'Garage', economic_sector_id: mecanicos.id}
# 	])
# 	podologia_dic = EconomicSectorsDictionary.create([
# 		{name: 'Centros de Podologia', economic_sector_id: podologia.id},
# 		{name: 'Podología', economic_sector_id: podologia.id},
# 		{name: 'Podologia', economic_sector_id: podologia.id}
# 	])
# 	artes_mariales_dic = EconomicSectorsDictionary.create([
# 		{name: 'Arte Marcial', economic_sector_id: artes_mariales.id}
# 	])
# 	yoga_dic = EconomicSectorsDictionary.create([
# 		{name: 'Yoga', economic_sector_id: yoga.id}
# 	])
# 	spas_dic = EconomicSectorsDictionary.create([
# 		{name: 'SPA', economic_sector_id: spas.id}
# 	])
# 	centros_deportivos_dic = EconomicSectorsDictionary.create([
# 		{name: 'Deporte', economic_sector_id: centros_deportivos.id}
# 	])

# # => Tags para la búsqueda
# 	# Estetica
# 		corte_estetica = Tag.create(name: "Corte", economic_sector_id: estetica.id)
# 		tintura_estetica = Tag.create(name: "Tinturas", economic_sector_id: estetica.id)
# 		depilacion_estetica = Tag.create(name: "Depilación", economic_sector_id: estetica.id)
# 		maquillaje_estetica = Tag.create(name: "Maquillaje", economic_sector_id: estetica.id)
# 		lavado_estetica = Tag.create(name: "Lavado", economic_sector_id: estetica.id)
# 		masaje_estetica = Tag.create(name: "Masajes", economic_sector_id: estetica.id)
# 	# Odontologia
# 		blanquiamiento_dentista = Tag.create(name: "Blanquiamiento", economic_sector_id: dentistas.id)
# 		canales_dentista = Tag.create(name: "Tratatimendo de Conducto", economic_sector_id: dentistas.id)
# 		caries_dentista = Tag.create(name: "Caries", economic_sector_id: dentistas.id)
# 	# Kinesiologia
# 		kinesioterapia_kinesiologia = Tag.create(name: "Kinesioterapia", economic_sector_id: kinesiologia.id)
# 		reabilitacion_kinesiologia = Tag.create(name: "Reabilitacion", economic_sector_id: kinesiologia.id)
# 		masaje_kinesiologia = Tag.create(name: "Masaje", economic_sector_id: kinesiologia.id)
# 	# Psicologia
# 		hipnosis_psicologia = Tag.create(name: "Hipnosis", economic_sector_id: sicologia.id)
# 		rehabilitacion_psicologia = Tag.create(name: "Rehabilitación", economic_sector_id: sicologia.id)
# 		consulta_psicologia = Tag.create(name: "Consulta", economic_sector_id: sicologia.id)
# 		psicoanalisis_psicologia = Tag.create(name: "Psicoanálisis", economic_sector_id: sicologia.id)
# 	# Medicina Alternativa
# 		dieta_med_alt = Tag.create(name: "Dieta", economic_sector_id: med_alt.id)
# 		remedios_med_alt = Tag.create(name: "Remedios Naturales", economic_sector_id: med_alt.id)
# 		acupuntura_med_alt = Tag.create(name: "Acupuntura", economic_sector_id: med_alt.id)
# 		tratamiento_med_alt = Tag.create(name: "Tratamiento Especiales", economic_sector_id: med_alt.id)
# 	# Talleres Mecanicos
# 		reparacion_mecanicos = Tag.create(name: "Reparación", economic_sector_id: mecanicos.id)
# 		chequeo_mecanicos = Tag.create(name: "Chequeo", economic_sector_id: mecanicos.id)
# 		aceite_mecanicos = Tag.create(name: "Cambio de Aceite", economic_sector_id: mecanicos.id)
# 	# Centros de Podologia
# 		pies_podologia = Tag.create(name: "Pies", economic_sector_id: podologia.id)
# 	# Artes Marciales
# 		karate_artes_marciales = Tag.create(name: "Karate", economic_sector_id: artes_mariales.id)
# 		fullcontact_artes_marciales = Tag.create(name: "Fullcontact", economic_sector_id: artes_mariales.id)
# 		Taekwando_artes_marciales = Tag.create(name: "Taekwando", economic_sector_id: artes_mariales.id)
# 		kungfu_artes_marciales = Tag.create(name: "Kung Fu", economic_sector_id: artes_mariales.id)
# 		jiujitzu_artes_marciales = Tag.create(name: "JiuJitzu", economic_sector_id: artes_mariales.id)
# 	# Yoga
# 		relajacion_yoga = Tag.create(name: "Yoga", economic_sector_id: yoga.id)
# 	# SPA
# 		relajacion_spa = Tag.create(name: "Relajación", economic_sector_id: spas.id)
# 		reduccion_spa = Tag.create(name: "Reducción", economic_sector_id: spas.id)
# 		descontracturante_spa = Tag.create(name: "Descontracturante", economic_sector_id: spas.id)
# 	# Centros Deportivos
# 		cancha_centros_deportivos = Tag.create(name: "Cancha", economic_sector_id: centros_deportivos.id)
# 		pista_centros_deportivos = Tag.create(name: "Pista", economic_sector_id: centros_deportivos.id)

# # => Diccionatio Tags
# 	depilacion_estetica_dic = Dictionary.create([
# 		{name: "Rebaje", tag_id: depilacion_estetica.id},
# 		{name: "Cera", tag_id: depilacion_estetica.id},
# 		{name: "Depilacion", tag_id: depilacion_estetica.id},
# 	])
# 	maquillaje_estetica_dic = Dictionary.create([
# 		{name: "Polvo", tag_id: maquillaje_estetica.id},
# 		{name: "Polvos", tag_id: maquillaje_estetica.id},
# 		{name: "Colorete", tag_id: maquillaje_estetica.id},
# 		{name: "Sombra", tag_id: maquillaje_estetica.id},
# 		{name: "Base", tag_id: maquillaje_estetica.id}
# 	])
# 	tintura_estetica_dic = Dictionary.create([
# 		{name: "Tinturas", tag_id: tintura_estetica.id},
# 		{name: "Teñir", tag_id: tintura_estetica.id},
# 		{name: "Teñido", tag_id: tintura_estetica.id},
# 		{name: "Pelo", tag_id: tintura_estetica.id}
# 	])
# 	corte_estetica_dic = Dictionary.create([
# 		{name: "Recorte", tag_id: corte_estetica.id},
# 		{name: "Cortes", tag_id: corte_estetica.id},
# 		{name: "Pelo", tag_id: corte_estetica.id}
# 	])
# 	lavado_estetica_dic = Dictionary.create([
# 		{name: "Hidrolavado", tag_id: lavado_estetica.id},
# 		{name: "Pelo", tag_id: lavado_estetica.id},
# 	])
# 	blanquiamiento_dentista_dic = Dictionary.create([
# 		{name: "Diente", tag_id: blanquiamiento_dentista.id},
# 		{name: "Pulido", tag_id: blanquiamiento_dentista.id}
# 	])
# 	canales_dentista_dic = Dictionary.create(name: "Tratamiento de Canales", tag_id:canales_dentista.id)
# 	caries_dentista_dic = Dictionary.create(name: "Carie", tag_id: caries_dentista.id)
# 	kinesioterapia_kinesiologia_dic = Dictionary.create([
# 		{name: "Terapia", tag_id: kinesioterapia_kinesiologia.id},
# 		{name: "Lesión", tag_id: kinesioterapia_kinesiologia.id},
# 		{name: "Lesion", tag_id: kinesioterapia_kinesiologia.id}
# 	])
# 	reabilitacion_kinesiologia_dic = Dictionary.create([
# 		{name: "Terapia", tag_id: reabilitacion_kinesiologia.id},
# 		{name: "Desgarro", tag_id: reabilitacion_kinesiologia.id},
# 		{name: "Lesión", tag_id: reabilitacion_kinesiologia.id},
# 		{name: "Lesion", tag_id: reabilitacion_kinesiologia.id}
# 	])
# 	masaje_kinesiologia_dic = Dictionary.create(name: "Relajacion", tag_id: masaje_kinesiologia.id)
# 	rehabilitacion_psicologia_dic = Dictionary.create(name: "Terapia", tag_id: rehabilitacion_psicologia.id)
# 	psicoanalisis_psicologia_dic = Dictionary.create(name: "Psico", tag_id: psicoanalisis_psicologia.id)
# 	karate_artes_marciales_dic = Dictionary.create(name: "carate", tag_id: karate_artes_marciales.id)
# 	kungfu_artes_marciales_dic = Dictionary.create(name: "Kungfu", tag_id: kungfu_artes_marciales.id)
# 	jiujitzu_artes_marciales_dic = Dictionary.create(name: "Jujitzu", tag_id: jiujitzu_artes_marciales.id)
# 	relajacion_spa_dic = Dictionary.create(name: "Relajacion", tag_id: relajacion_spa.id)
# 	reduccion_spa_dic = Dictionary.create(name: "Reduccion", tag_id: reduccion_spa.id)


# # => Países Activos
# 	countries = Country.create(name: "Chile")

# # => Regiones de los países activos 
# 	regions = Region.create(name: "Metropolitana", country: countries)

# # => Ciudades Activas 
# 	cities = City.create(name: "Santiago", region: regions)

# # => Comunas Activas 
# 	las_condes = District.create(name: "Las Condes", city: cities)
# 	providencia = District.create(name: "Providencia", city: cities)
# 	vitacura = District.create(name: "Vitacura", city: cities)
# 	nunoa = District.create(name: "Ñuñoa", city: cities)
# 	santiago = District.create(name: "Santiago", city: cities)
# 	lo_barnechea = District.create(name: "Lo Barnechea", city: cities)
# 	la_florida = District.create(name: "La Florida", city: cities)
# 	la_reina = District.create(name: "La Reina", city: cities)

# # => Planes Disponibles
# 	plan_personal = Plan.create(name: "Personal", locations: 1, service_providers: 1, custom: false, price: 14900, special: false)
# 	plan_basico = Plan.create(name: "Básico", locations: 1, service_providers: 30, custom: false, price: 24900, special: false)
# 	plan_normal = Plan.create(name: "Normal", locations: 2, service_providers: 60, custom: false, price: 39900, special: false)
# 	plan_premium = Plan.create(name: "Premium", locations: 3, service_providers: 90, custom: false, price: 49900, special: false)
# 	plan_trial = Plan.create(name: "Trial", locations: 5, service_providers: 90, custom: true, price: 0, special: false)
# 	plan_admin = Plan.create(name: "Admin", locations: 30, service_providers: 1, custom: true, price: 0, special: false) 
# 	# Plan para las personas que partieron con nosotros antes en la Beta y no se han querido cambiar...
# 	plan_beta = Plan.create(name: "Beta", locations: 1, service_providers: 2, custom: true, price: 14900, special: false)


# # => Test Company
# 	# test_company = Company.create(name: 'Test Company', web_address: 'test', economic_sector_id: 1, plan_id: 2, payment_status_id: 1, description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus pharetra quam neque, eget condimentum purus semper id. In porta ut mauris id congue. Quisque accumsan mauris nec turpis tincidunt, quis rhoncus augue porttitor. Mauris quis malesuada sem. Donec nisi metus.", cancellation_policy: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aliquam tincidunt rutrum sapien vel ultricies. Sed.")

# 	# test_setting = CompanySetting.create(before_booking: 24, after_booking: 6, company_id: test_company.id)

# 	# local_test = Location.create(name: 'Test Location', address: 'Nuestra Sra de Los Ángeles 185', phone: '+56 9 5178 5898', district_id: 1, company_id: 1, latitude: -33.4129192, longitude: -70.5921359)

# 	# service_categories_test = ServiceCategory.create(name: "Categoría de Prueba", company_id: test_company.id)

# 	# location_times = LocationTime.create([{open: '09:00', close: '18:30', location_id: local_test.id, day_id: 1}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 2}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 3}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 4}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 5}])

# 	# service = Service.create([{name: "Corte de pelo", price: 5500, duration: 30, company_id: test_company.id, service_category_id: service_categories_test.id}, {name: "Visos", price: 12000, duration: 45, company_id: test_company.id, service_category_id: service_categories_test.id}])

# 	# Service.find(1).tags << Tag.find(1)
# 	# Service.find(2).tags << Tag.find(2)

# 	# admin = User.create(first_name: 'Nicolás', last_name: 'Flores', email: 'nflores@agendapro.cl', phone: '+56 9 9719 8689', role: Role.find_by_name('Administrador General'), password: '12345678', password_confirmation: '12345678', company_id: test_company.id)

# 	# service_provider = ServiceProvider.create(location_id: local_test.id, company_id: test_company.id, notification_email: 'nflores@agendapro.cl', public_name: 'Provider Test')

# 	# service_provider.services << service

# 	# provider_times = ProviderTime.create([
# 	# 	{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 1},
# 	# 	{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 2},
# 	# 	{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 3},
# 	# 	{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 4},
# 	# 	{open: '9:00', close: '18:00', service_provider_id: 1, day_id: 5}
# 	# ])

# 	# user = User.create(first_name: 'Nicolás', last_name: 'Rossi', email: 'nrossi@agendapro.cl', phone: '+56 9 8289 7145', role: Role.find_by_name('Usuario Registrado'), password: '12345678', password_confirmation: '12345678')
