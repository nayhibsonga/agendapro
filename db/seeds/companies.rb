# => Empresas de prueba
	#company_owner = User.find_by_email("iegomez@agendapro.cl")


	#plan_ids = Plan.all
	addresses = Array.new
	addresses[0] = "Apoquindo" #3000 a 4000
	addresses[1] = "Pdte Riesco" #4000
	addresses[2] = "Pdte Errázuriz" #4000

	for i in 1..12

		puts "Creando compañía " + i.to_s + "..."
		eco_sector = EconomicSector.new(:name => Faker::Commerce.department)

		if(eco_sector.save)
			puts "Creado sector económico: " + eco_sector.name
		end

		
		test_company = Company.new(name: Faker::Company.name, web_address: Faker::Company.suffix, plan_id: 8, payment_status_id: 1, description: Faker::Lorem.paragraph)
		test_company.economic_sectors << eco_sector
		test_company.build_company_setting
		if(test_company.save)
			puts "Compañía creada: " + test_company.name
		else
			puts "Error"
			abort
		end
		#test_setting = CompanySetting.create(before_booking: 24, after_booking: 6, company_id: test_company.id)

		#Locales de prueba
		for j in 1..15
			puts "Creando local " + j.to_s + "..."
			address = addresses[rand(2)] + " " + (3000+rand(1000)).to_s
			coord = Geocoder.coordinates(address)
			local_test = Location.new(name: Faker::Company.name, address: address, phone: '+56 9 5178 5898', district_id: 1, latitude: coord[0], longitude: coord[1], outcall: false)
			local_test.company_id = test_company.id
			if (local_test.save)
				puts "Local creado: " + local_test.name
			else
				puts "Error"
				abort
			end
			
			service_categories_test = ServiceCategory.create(name: Faker::Commerce.department, company_id: test_company.id)
			location_times = LocationTime.create([{open: '09:00', close: '18:30', location_id: local_test.id, day_id: 1}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 2}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 3}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 4}, {open: '09:00', close: '18:30', location_id: local_test.id, day_id: 5}])
			service = Service.create([{name: Faker::Commerce.product_name, price: 5500, duration: 30, company_id: test_company.id, service_category_id: service_categories_test.id}, {name: Faker::Commerce.product_name, price: 12000, duration: 45, company_id: test_company.id, service_category_id: service_categories_test.id}])

			user = User.create(first_name: Faker::Name.first_name, last_name: Faker::Name.last_name, email: Faker::Internet.email, phone: '+56 9 9719 8689', role: Role.find_by_name('Administrador General'), password: '12345678', password_confirmation: '12345678', company_id: test_company.id)

			service_provider = ServiceProvider.create(location_id: local_test.id, company_id: test_company.id, notification_email: 'iegomez@agendapro.cl', public_name: Faker::Name.name)

			service_provider.services << service

			provider_times = ProviderTime.create([
				{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 1},
				{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 2},
				{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 3},
				{open: '09:00', close: '18:00', service_provider_id: 1, day_id: 4},
				{open: '9:00', close: '18:00', service_provider_id: 1, day_id: 5}
			])

		end

	end