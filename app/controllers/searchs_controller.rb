class SearchsController < ApplicationController
	layout "search"

	def index
	end

	def search
		district = District.find(params[:district])
		city = district.city
		region = city.region
		country = region.country
		@geolocation = district.name + ', ' + city.name + ', ' + region.name + ', ' + country.name

		@results = Array.new

		# filtrar pronombres y articulos
		search = '%' + params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%') + '%'

		# 	optener de los locales los servicios cuyo tag coincide con la busqueda
		tags = Tag.includes(:dictionaries).where('dictionaries.name ILIKE ? OR tags.name ILIKE ?', search, search)
		services_tags = Service.includes(:tags).where(:tags => {:id => tags.pluck(:id)})
		service_providers = ServiceProvider.includes(:services).where(:services => {:id => services_tags.pluck(:id)}).pluck(:location_id)
		locations_tags = Location.where(district_id: params[:district], id: service_providers)
		# @results.push(locations_tags)
		locations_tags.each do |location_tag|
			@results.push(location_tag)
		end

		# 	optener de los locales los servicios cuyo nombre coincide con la busqueda
		services_tags = Service.where('name ILIKE ?', search)
		service_providers = ServiceProvider.joins(:services, :service_staffs).where('service_staffs.service_id' => services_tags).select('location_id')
		locations_services = Location.where(district_id: params[:district], id: service_providers)
		# @results.push(locations_services)
		locations_services.each do |location_service|
			@results.push(location_service)
		end

		# 	optener los locales cuyo nombre se parece a la busqueda
		locations = Location.where(district_id: params[:district]).where('name ILIKE ?', search)
		# @results.push(locations)
		locations.each do |location|
			@results.push(location)
		end

		# 	optener los locales de las compañias cuyo nombre se parece a la busqueda
		locations_companies = Location.where(district_id: params[:district]).where(company_id: Company.where('name ILIKE ?', search))
		# @results.push(locations_companies)
		locations_companies.each do |location_company|
			@results.push(location_company)
		end

		respond_to do |format|
			format.html
			format.json { render :json => @results }
		end
	end
end
