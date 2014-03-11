class SearchsController < ApplicationController
	layout "search"

	def index
	end

	def search
		# => Domain parser
		host = request.host_with_port
		@domain = host[host.index(request.domain)..host.length]

		# => Geolocation
		district = District.find(params[:district])
		city = district.city
		region = city.region
		country = region.country
		@geolocation = district.name + ', ' + city.name + ', ' + region.name + ', ' + country.name

		@results = Array.new

		# => filtrar pronombres y articulos
		search = '%' + params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%') + '%'

		# => optener de los locales los servicios cuyo tag coincide con la busqueda
		tags = Tag.includes(:dictionaries).where('dictionaries.name ILIKE ? OR tags.name ILIKE ?', search, search)
		services_tags = Service.includes(:tags).where(:tags => {:id => tags.pluck(:id)})
		service_providers = ServiceProvider.includes(:services).where(:services => {:id => services_tags.pluck(:id)}).pluck(:location_id)
		locations_tags = Location.where(district_id: params[:district], id: service_providers)

		locations_tags.each do |location_tag|
			@results.push(location_tag)
		end

		# => Optener los locales pertenecientes a las compañias cuyo rubro se parece a la busqueda
		locations_companies_economic_sector = Location.where(district_id: params[:district]).where(company_id: Company.where(economic_sector_id: EconomicSector.where('name ILIKE ?', search)))
		puts locations_companies_economic_sector
		locations_companies_economic_sector.each do |location_company_economic_sector|
			@results.push(location_company_economic_sector)
		end

		# => optener de los locales los servicios cuyo nombre coincide con la busqueda
		services_tags = Service.where('name ILIKE ?', search)
		service_providers = ServiceProvider.joins(:services, :service_staffs).where('service_staffs.service_id' => services_tags).select('location_id')
		locations_services = Location.where(district_id: params[:district], id: service_providers)

		locations_services.each do |location_service|
			@results.push(location_service)
		end

		# => optener los locales cuyo nombre se parece a la busqueda
		locations = Location.where(district_id: params[:district]).where('name ILIKE ?', search).order(:name)

		locations.each do |location|
			@results.push(location)
		end

		# => optener los locales de las compañias cuyo nombre se parece a la busqueda
		locations_companies = Location.where(district_id: params[:district]).where(company_id: Company.where('name ILIKE ?', search).order(:name))

		locations_companies.each do |location_company|
			@results.push(location_company)
		end

		# => optener los locales de las compañias cuya url se parece a la busqueda
		locations_companies_url = Location.where(district_id: params[:district]).where(company_id: Company.where('web_address ILIKE ?', search).order(:web_address))

		locations_companies_url.each do |locations_company|
			@results.push(locations_company)
		end

		# => eliminamos los resultados repetidos
		@results = @results.uniq

		respond_to do |format|
			format.html
			format.json { render :json => @results }
		end
	end
end
