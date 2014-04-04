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

		lat = params[:latitude]
		long = params[:longitude]

		@results = Array.new

		# => filtrar pronombres y articulos
		search = '%' + params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%') + '%'

		# => optener de los locales los servicios cuyo tag coincide con la busqueda
		tags = Tag.includes(:dictionaries).where('dictionaries.name ILIKE ? OR tags.name ILIKE ?', search, search)
		services_tags = Service.includes(:tags).where(:tags => {:id => tags.pluck(:id)})
		service_providers = ServiceProvider.includes(:services).where(:services => {:id => services_tags.pluck(:id)}).pluck(:location_id)
		locations_tags = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1', id: service_providers).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		locations_tags.each do |location_tag|
			@results.push(location_tag)
		end

		# => Optener los locales pertenecientes a las compañias cuyo rubro se parece a la busqueda
		economic_sector = EconomicSector.includes(:economic_sectors_dictionaries).where('economic_sectors.name ILIKE ? OR economic_sectors_dictionaries.name ILIKE ?', search, search)
		locations_companies_economic_sector = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1').where(company_id: Company.where(economic_sector_id: economic_sector.pluck(:id))).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')
		locations_companies_economic_sector.each do |location_company_economic_sector|
			@results.push(location_company_economic_sector)
		end

		# => optener de los locales los servicios cuyo nombre coincide con la busqueda
		services_tags = Service.where('name ILIKE ?', search)
		service_providers = ServiceProvider.joins(:services, :service_staffs).where('service_staffs.service_id' => services_tags).select('location_id')
		locations_services = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1', id: service_providers).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		locations_services.each do |location_service|
			@results.push(location_service)
		end

		# => optener los locales cuyo nombre se parece a la busqueda
		locations = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1').where('name ILIKE ?', search).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		locations.each do |location|
			@results.push(location)
		end

		# => optener los locales de las compañias cuyo nombre se parece a la busqueda
		locations_companies = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1').where(company_id: Company.where('name ILIKE ?', search).order(:name)).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

		locations_companies.each do |location_company|
			@results.push(location_company)
		end

		# => optener los locales de las compañias cuya url se parece a la busqueda
		locations_companies_url = Location.where('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2) <= 0.1').where(company_id: Company.where('web_address ILIKE ?', search).order(:web_address)).order('sqrt((latitude - ' + lat + ')^2 + (longitude - ' + long + ')^2)')

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
