class SearchsController < ApplicationController
	layout "search"

	def index
	end
	  

	def search
		# => Domain parser
		host = request.host_with_port
		@domain = host[host.index(request.domain)..host.length]

		lat = params[:latitude]
		long = params[:longitude]

		# => filtrar pronombres y articulos
		search = '%' + params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%') + '%'

		# => obtener de los locales los servicios cuyo tag coincide con la busqueda
		tags = Tag.includes(:dictionaries).where('dictionaries.name ILIKE ? OR tags.name ILIKE ?', search, search)
		services_tags = Service.where(:active => true).includes(:tags).where(:tags => {:id => tags.pluck(:id)}).pluck(:id)
		service_providers_tags = ServiceProvider.where(active: true).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, id: services_tags).pluck(:id) ).pluck(:location_id).uniq

		# => obtener los locales pertenecientes a las compañias cuyo rubro se parece a la busqueda
		economic_sectors = EconomicSector.includes(:economic_sectors_dictionaries).where('economic_sectors.name ILIKE ? OR economic_sectors_dictionaries.name ILIKE ?', search, search).pluck(:id).uniq
		company_economic_sector = Company.includes(:company_economic_sectors).where('company_economic_sectors.economic_sector_id IN (?)', economic_sectors).pluck(:id).uniq

		# => obtener de los locales los servicios cuyo nombre coincide con la busqueda
		services = Service.where(:active => true).where('name ILIKE ?', search)
		service_providers_services = ServiceProvider.where(:active => true).joins(:services, :service_staffs).where('service_staffs.service_id' => services).pluck(:location_id).uniq

		companies = Company.where(active: true, owned: true).where('name ILIKE ? OR web_address ILIKE ? OR id IN (?)', search, search, company_economic_sector).uniq.pluck(:id)

		locations = Location.where(id: service_providers_tags).where(id: service_providers_services).uniq.pluck(:id)

		@results1 = Location.select('locations.*, sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)').where(:active => true, company_id: Company.where(id: CompanySetting.where(activate_search: true, activate_workflow: true).pluck(:company_id), active: true, owned: true)).where(id: ServiceProvider.where(active: true).joins(:provider_times).pluck(:location_id)).where('name ILIKE ? OR id IN (?) OR company_id IN (?)', search, locations, companies).uniq.order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		companies2 = Company.where(active: true, owned: false).where('name ILIKE ? OR web_address ILIKE ? OR id IN (?)', search, search, company_economic_sector).uniq.pluck(:id)

		@results2 = Location.select('locations.*, sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)').where(:active => true, company_id: Company.where(id: CompanySetting.where(activate_search: true, activate_workflow: true).pluck(:company_id), active: true, owned: false)).where('name ILIKE ? OR company_id IN (?)', search, companies2).uniq.order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		@results = (@results1 + @results2).paginate(:page => params[:page], :per_page => 10)

		@lat = lat
		@long = long

		i = 1
		@results.each do |location|
			if !File.exist?("app/assets/images/search/pin_map#{i}.png")
				img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
				img.combine_options do |c|
			    	c.draw "text 9,22 '#{i.to_s}'"
					c.fill("#FFFFFF")
					c.pointsize "17"
				end
				img.write("app/assets/images/search/pin_map#{i}.png")
			end
			i = i+1			
		end

		respond_to do |format|
			format.html
			format.json { render :json => @results }
		end
	end

	def get_pin
		num = params[:number]
		respond_to do |format|
			format.html
			format.json { render :json => @results }
		end
	end

end
