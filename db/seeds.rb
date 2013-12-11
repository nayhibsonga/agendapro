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

plans = Plan.create(name: "Básico", locations: 3, staffs: 10, custom: false)

roles = Role.create([{name: "Super Admin", description: "Administrador de la aplicaión AgendaPro"}, {name: "Admin", description: "Administrador de empresa inscrita en AgendaPro"}, {name: "Administrador Local", description: "Administrador de local"}, {name: "Staff", description: "Usuario con atribuciones de atención en su local"}, {name: "Usuario Registrado", description: "Usuario con cuenta registrada y accesible"}, {name: "Usuario No Registrado", description: "Usuario con cuenta no registrada"}])