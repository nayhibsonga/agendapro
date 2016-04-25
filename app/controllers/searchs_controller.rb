# encoding: utf-8
class SearchsController < ApplicationController

	layout "results", except: [:index, :landing]
	require 'amatch'
	require 'benchmark'
	include Amatch


  	before_action :constraint_locale, only: [:promotions, :last_minute_promotions]

	def landing
		if params[:redirect_params].present?
			redirect = eval(params[:redirect_params])
		end

		render layout: "empty"
	end

	def index
		@lat = cookies[:lat].to_f
		@lng = cookies[:lng].to_f
		if cookies[:formatted_address]
			@formatted_address = cookies[:formatted_address].unpack("C*").pack("U*")
		end
		@companies =  Company.where(id: CompanySetting.where(activate_search: true, activate_workflow: true).pluck(:company_id), country_id: Country.find_by(locale: I18n.locale.to_s), payment_status_id: [PaymentStatus.find_by_name("Activo"), PaymentStatus.find_by_name("Convenio PAC"), PaymentStatus.find_by_name("Emitido"), PaymentStatus.find_by_name("Vencido")]).where.not(logo: nil)
		render layout: "search"
	end

	def search

		if params[:inputSearch].present? && params[:latitude].present? && params[:longitude].present? && params[:inputLocalization].present?

			@lat = params[:latitude]
			@lng = params[:longitude]

			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			end
			# => Domain parser
			host = request.host_with_port
			@domain = host[host.index(request.domain)..host.length]


			lat = params[:latitude]
			long = params[:longitude]

			@latitude = params[:latitude]
			@longitude = params[:longitude]

			@results = Array.new
			@empty_results = Array.new

			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s


			#EMPRESAS CON DUEÑO

			#query_company_name = Location.search_company_name(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

			#rest
			#query_rest = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25') - query_company_name


			#query = query_company_name + query_rest


			# query1 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.025')

			# query2 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.05 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.025')

			# query3 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.075 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.05')

			# query4 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.10 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.075')

			# query5 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.125 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.10')

			# query6 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.15 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.125')

			# query7 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.175 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.15')

			# query8 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.20 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.175')

			# query9 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.225 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.20')

			# query10 = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.225')


			# query = query1 + query2 + query3 + query4 + query5 + query6 + query7 + query8 + query9 + query10


			# # Divide the results in a reasonable amount of subgroups in order
			# # to rank by distance only inside those groups
			# # For now, subgroups whill have max 10 locations

			# locs = Array.new
			# ordered_locs = Array.new

			# if query.count > 10

			# 	count = (query.count.to_f / 10).ceil
			# 	results = Array.new

			# 	current_rank = query[0].pg_search_rank
			# 	current_group = Array.new
			# 	query.each do |res|
			# 		if res.pg_search_rank <= current_rank && (res.pg_search_rank - current_rank).abs < 0.015
			# 			current_group << res
			# 		else
			# 			results << current_group
			# 			current_group = Array.new
			# 			current_group << res
			# 			current_rank = res.pg_search_rank
			# 		end
			# 	end
			# 	results << current_group

			# 	j = 0
			# 	results.each do |result|
			# 		locs[j] = Array.new
			# 		result.each do |location|
			# 			dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
			# 			local = [location, dist_score]
			# 			locs[j].push(local)
			# 		end
			# 		j = j+1
			# 	end

			# 	for i in 0..j-1
			# 		ordered_locs[i] = locs[i].sort_by{ |loc| loc[1]}
			# 	end

			# else
			# 	query.each do |location|
			# 		dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
			# 		local = [location, dist_score]
			# 		locs.push(local)
			# 	end
			# 	ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
			# end

			# #FIN EMPRESAS CON DUEÑO

			# #EMPRESAS SIN DUEÑO

			# unowned_query1 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.025')

			# unowned_query2 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.05 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.025')

			# unowned_query3 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.075 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.05')

			# unowned_query4 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.10 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.075')

			# unowned_query5 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.125 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.10')

			# unowned_query6 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.15 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.125')

			# unowned_query7 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.175 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.15')

			# unowned_query8 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.20 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.175')

			# unowned_query9 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.225 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.20')

			# unowned_query10 = Location.search(normalized_search).where(online_booking: true).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25 and sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) >= 0.225')


			# unowned_query = unowned_query1 + unowned_query2 + unowned_query3 + unowned_query4 + unowned_query5 + unowned_query6 + unowned_query7 + unowned_query8 + unowned_query9 + unowned_query10



			# #unowned_query_company_names = Location.search_company_name(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

			# #unowned_query_rest = Location.search(normalized_search).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => false).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25') - unowned_query_company_names


			# #unowned_query = unowned_query_company_names + unowned_query_rest

			# unowned_locs = Array.new
			# unowned_ordered_locs = Array.new


			# if unowned_query.count > 10

			# 	count = (unowned_query.count.to_f / 10).ceil
			# 	unowned_results = Array.new

			# 	current_rank = unowned_query[0].pg_search_rank
			# 	current_group = Array.new
			# 	unowned_query.each do |res|
			# 		if res.pg_search_rank <= current_rank && (res.pg_search_rank - current_rank).abs < 0.015
			# 			current_group << res
			# 		else
			# 			unowned_results << current_group
			# 			current_group = Array.new
			# 			current_group << res
			# 			current_rank = res.pg_search_rank
			# 		end
			# 	end
			# 	unowned_results << current_group

			# 	j = 0
			# 	unowned_results.each do |unowned_result|
			# 		unowned_locs[j] = Array.new
			# 		unowned_result.each do |location|
			# 			dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
			# 			local = [location, dist_score]
			# 			unowned_locs[j].push(local)
			# 		end
			# 		j = j+1
			# 	end

			# 	for i in 0..j-1
			# 		unowned_ordered_locs[i] = unowned_locs[i].sort_by{ |loc| loc[1]}
			# 	end

			# else
			# 	unowned_query.each do |location|
			# 		dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
			# 		local = [location, dist_score]
			# 		unowned_locs.push(local)
			# 	end
			# 	unowned_ordered_locs[0] = unowned_locs.sort_by{ |loc| loc[1]}
			# end


			# #FIN EMPRESAS SIN DUEÑO

			# @results = Array.new

			# ordered_locs.each do |arr|
			# 	arr.each do |s|
			# 		@results << s[0]
			# 	end
			# end

			# unowned_ordered_locs.each do |arr|
			# 	arr.each do |s|
			# 		@results << s[0]
			# 	end
			# end

			query = "SELECT * FROM locations_search('#{normalized_search}',#{lat},#{long})"
			results = ActiveRecord::Base.connection.execute(query)

			results.each do |result|
				@results << Location.find(result['location_id'])
			end

			per_page = 10

			@results = @results.paginate(:page => params[:page], :per_page => per_page)

			i = 1
			for i in 1..per_page
				if !File.exist?("app/assets/images/search/pin_map#{i}.png")
					img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
					if i<10
						img.combine_options do |c|
					    	c.draw "text 9,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					elsif i<100
						img.combine_options do |c|
					    	c.draw "text 4,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					else
						img.combine_options do |c|
					    	c.draw "text 1,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					end

					img.write("app/assets/images/search/pin_map#{i}.png")
				end
			end


			respond_to do |format|
				format.html
				format.json { render :json => @results }
			end
		else
			redirect_to root_path
		end


	end

	def search2
		if params[:inputSearch] && params[:latitude] && params[:longitude] && params[:inputLocalization]
			@lat = params[:latitude]
			@lng = params[:longitude]



			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].unpack("C*").pack("U*")
			end
			# => Domain parser
			host = request.host_with_port
			@domain = host[host.index(request.domain)..host.length]

			# if(!@lat)
			# 	lat = params[:latitude]
			# else
			# 	lat = @lat
			# end
			# if(!@long)
			# 	long = params[:longitude]
			# else
			# 	long = @long
			# end

			lat = params[:latitude]
			long = params[:longitude]



			@latitude = params[:latitude]
			@longitude = params[:longitude]


			@results = Array.new
			@empty_results = Array.new

			#Filtrado de pronombres y artículos
			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

			#Segmentos de locales según resultados
			loc_segments = Array.new
			empty_loc_segments = Array.new

			for i in 0..7
				loc_segments[i] = Array.new
				empty_loc_segments[i] = Array.new
			end

			#Filtrado de pronombres y artículos
			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s


			## Se eligen los locales activos de empresas activas
 			#active_companies_ids = Company.where(active: true).pluck(:id)
			#elegible_locations = Location.where(active: true, company_id: active_companies_ids)
			## Se eligen locales que tengan horarios, que a su vez tengan prestadores con horarios y servicios asociados
			#elegible_locations = elegible_locations.where(id: ServiceProvider.where(active: true, company_id: active_companies_ids).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: active_companies_ids).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)
			## Se eligen locales dentro del rango
			#locations = elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25') #Location.all
 			#loc_ids = Array.new


			# if(Company.where('lower(name) LIKE ? and active = ?', "%#{normalized_search}%", true).count > 0)
			# 	matching_companies_ids = Company.where('lower(name) LIKE ? and active = ?', "%#{normalized_search}%", true).pluck(:id)
			# 	elegible_locations = Location.where(:active => true).where(company_id: matching_companies_ids).where(id: ServiceProvider.where(active: true, company_id: matching_companies_ids).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: matching_companies_ids).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)
			# 	locations = elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

			# 	locations.each do |location|
			# 		dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
			# 		local = [location, dist_score]
			# 		loc_segments[0].push(local)
			# 	end
			# end

			m1 = JaroWinkler.new(normalized_search)
			m2 = PairDistance.new(normalized_search)



			economic_sectors = EconomicSector.joins(:companies).where("companies.id" => Company.where(:owned => true, :active => true))

			empty_economic_sectors = EconomicSector.joins(:companies).where("companies.id" => Company.where(:owned => false, :active => true))


			#
			# EMPRESAS CON DUEÑO
			#

			#Guardamos los score de los sectores economicos para no calcularlos varias veces
			economic_scores = Hash.new

			#Iteramos en los economic sectors
			economic_sectors .each do |sector|

				#Obtenemos el puntaje del economic sector
				economics_max = 0

				score1 = m1.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
				score2 = m2.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
				economics_max = score1
				if(score2 > economics_max)
					economics_max = score2
				end

				economic_scores[sector.id] = economics_max



			end #Ends economic_sectors


			#Iteramos sobre las compañías porque un local sólo tiene una compañía
			companies = Company.where(:active => true, :owned => true)
			companies.each do |company|

				company_max = 0

				str_test_array = company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s.split(' ')

				test_array = Array.new

				limit = str_test_array.count
				if limit>4
					limit = 4
				end

				for i in 0..limit-1
				 	str_test_array.permutation(i).to_a.each do |perm|
				 		test_array.push(perm)
					end
				end


				test_array.each do |ta|

				 	comScore1 = m1.match(ta.join(" "))
				 	comScore2 = m2.match(ta.join(" "))

				 	if(comScore1>company_max)
				 		company_max = comScore1
				 	end
				 	if(comScore2>company_max)
				 		company_max = comScore2
				 	end

				end


				providers_scores = Hash.new

				#Obtenemos los scores de services y service_providers de la compañía de antemano
				service_providers = ServiceProvider.where(company_id: company.id, active: true, online_booking: true)
				service_providers.each do |provider|



					score1 = m1.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
					score2 = m2.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)

					provider_max = score1
					if(score2 > provider_max)
						provider_max = score2
					end

					providers_scores[provider.id] = provider_max

				end


				#Obtenemos los puntajes de sus servicios
				services_scores = Hash.new
				services = Service.where(active: true, company_id: company.id)
				services.each do |service|

					score1 = m1.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
					score2 = m2.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)

					service_max = score1
					if(score2 > service_max)
						service_max = score2
					end

					services_scores[service.id] = service_max

				end



				#Iteramos sobre los locales de la compañía
				elegible_locations = Location.where(:active => true, online_booking: true, :company_id => company.id).where(id: ServiceProvider.where(active: true, online_booking: true, company_id: company.id).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, online_booking: true, company_id: company.id).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(:order, :name)
				locations = elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

				locations.each do |location|



					#Sólo nos falta calcular los puntajes de sus categorías y sacar el máximo de services, services_providers y economic_sectors
					catScore1 = 0
					catScore2 = 0
					location.categories.each do |category|


						score1 = m1.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
						score2 = m2.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
						if(score1 > catScore1)
							catScore1 = score1
						end
						if(score2 > catScore2)
							catScore2 = score2
						end

					end
					categories_max = catScore1
					if(catScore2>categories_max)
						categories_max = catScore2
					end

					#Providers scores
					providers_ids = ServiceProvider.where(location_id: location.id, :active => true, online_booking: true).pluck('id')
					loc_providers_scores = Array.new
					providers_ids.each do |pid|
						loc_providers_scores << providers_scores[pid]
					end

					providers_max = loc_providers_scores.max

					#Services scores
					loc_services_scores = Array.new
					location.service_providers.where(:active => true).each do |sp|
						sp.services.where(:active => true).each do |service|
							loc_services_scores << services_scores[service.id]
						end
					end

					services_max = loc_services_scores.max

					#Economic Sectors scores
					economic_ids = EconomicSector.joins(:companies).where("companies.id" => company.id).pluck('economic_sector_id')
					loc_economic_scores = Array.new
					economic_ids.each do |ecoid|
						loc_economic_scores << economic_scores[ecoid]
					end

					economics_max = loc_economic_scores.max

					max = economics_max
					if(categories_max>max)
						max = categories_max
					end
					if(services_max>max)
						max = services_max
					end
					if(company_max>max)
						max = company_max
					end
					if(providers_max > max)
						max = providers_max
					end

					#Segmentamos por puntaje, guardando las distancias

					for i in 0..7
						if((max >= (0.96 - i*0.04)))

							#Calculamos la distancia aproximada

							dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)

							#Si la distancia es mayor que el máximo por tramos, NO agregamos el local
							if i > 5
								if dist_score > 0.10
									break
								end
							elsif i > 3
								if dist_score > 0.175
									break
								end
							else
								if dist_score > 0.25
									break
								end
							end

							#Guardamos el local con su distancia
							local = [location, dist_score]
							loc_segments[i].push(local)

							break
						end
					end


				end

			end


			#
			# FIN EMPRESAS CON DUEÑO
			#



			#
			# EMPRESAS SIN DUEÑO
			#


			#Guardamos los score de los sectores economicos para no calcularlos varias veces
			economic_scores = Hash.new

			#Iteramos en los economic sectors
			empty_economic_sectors .each do |sector|

				#Obtenemos el puntaje del economic sector
				economics_max = 0

				score1 = m1.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
				score2 = m2.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
				economics_max = score1
				if(score2 > economics_max)
					economics_max = score2
				end

				economic_scores[sector.id] = economics_max



			end #Ends economic_sectors


			#Iteramos sobre las compañías porque un local sólo tiene una compañía
			companies = Company.where(:active => true, :owned => false)
			companies.each do |company|

				company_max = 0

				str_test_array = company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s.split(' ')

				test_array = Array.new

				limit = str_test_array.count
				if limit>4
					limit = 4
				end

				for i in 0..limit-1
				 	str_test_array.permutation(i).to_a.each do |perm|
				 		test_array.push(perm)
					end
				end

				test_array.each do |ta|

				 	comScore1 = m1.match(ta.join(" "))
				 	comScore2 = m2.match(ta.join(" "))

				 	if(comScore1>company_max)
				 		company_max = comScore1
				 	end
				 	if(comScore2>company_max)
				 		company_max = comScore2
				 	end

				end


				providers_scores = Hash.new

				#Obtenemos los scores de services y service_providers de la compañía de antemano
				service_providers = ServiceProvider.where(company_id: company.id, active: true, online_booking: true)
				service_providers.each do |provider|


					score1 = m1.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
					score2 = m2.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)

					provider_max = score1
					if(score2 > provider_max)
						provider_max = score2
					end

					providers_scores[provider.id] = provider_max

				end


				#Obtenemos los puntajes de sus servicios
				services_scores = Hash.new
				services = Service.where(active: true, company_id: company.id)
				services.each do |service|

					score1 = m1.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
					score2 = m2.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)

					service_max = score1
					if(score2 > service_max)
						service_max = score2
					end

					services_scores[service.id] = service_max

				end



				#Iteramos sobre los locales de la compañía
				elegible_locations = Location.where(:active => true, online_booking: true, :company_id => company.id).where(id: ServiceProvider.where(active: true, online_booking: true, company_id: company.id).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, online_booking: true, company_id: company.id).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(:order, :name)
				locations = elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

				locations.each do |location|



					#Sólo nos falta calcular los puntajes de sus categorías y sacar el máximo de services, services_providers y economic_sectors
					catScore1 = 0
					catScore2 = 0
					location.categories.each do |category|


						score1 = m1.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
						score2 = m2.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
						if(score1 > catScore1)
							catScore1 = score1
						end
						if(score2 > catScore2)
							catScore2 = score2
						end

					end
					categories_max = catScore1
					if(catScore2>categories_max)
						categories_max = catScore2
					end

					#Providers scores
					providers_ids = ServiceProvider.where(location_id: location.id, :active => true, online_booking: true).pluck('id')
					loc_providers_scores = Array.new
					providers_ids.each do |pid|
						loc_providers_scores << providers_scores[pid]
					end

					providers_max = loc_providers_scores.max

					#Services scores
					loc_services_scores = Array.new
					location.service_providers.where(:active => true).each do |sp|
						sp.services.where(:active => true).each do |service|
							loc_services_scores << services_scores[service.id]
						end
					end

					services_max = loc_services_scores.max

					#Economic Sectors scores
					economic_ids = EconomicSector.joins(:companies).where("companies.id" => company.id).pluck('economic_sector_id')
					loc_economic_scores = Array.new
					economic_ids.each do |ecoid|
						loc_economic_scores << economic_scores[ecoid]
					end

					economics_max = loc_economic_scores.max



					max = economics_max
					if(categories_max>max)
						max = categories_max
					end
					if(services_max>max)
						max = services_max
					end
					if(company_max>max)
						max = company_max
					end
					if(providers_max > max)
						max = providers_max
					end

					#Segmentamos por puntaje, guardando las distancias

					for i in 0..7
						if((max >= (0.96 - i*0.04)))

							#Calculamos la distancia aproximada

							dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)

							#Si la distancia es mayor que el máximo por tramos, NO agregamos el local
							if i > 5
								if dist_score > 0.10
									break
								end
							elsif i > 3
								if dist_score > 0.175
									break
								end
							else
								if dist_score > 0.25
									break
								end
							end

							#Guardamos el local con su distancia
							local = [location, dist_score]
							empty_loc_segments[i].push(local)

							break
						end
					end


				end

			end

			#
			# FIN EMPRESAS SIN DUEÑO
			#


			# active_companies_ids = Company.where(active: true, :owned => true).pluck(:id)
			# elegible_locations = Location.where(:active => true).where(company_id: active_companies_ids).where(id: ServiceProvider.where(active: true, company_id: active_companies_ids).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: active_companies_ids).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)
			# locations = elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25') #Location.all
			# loc_ids = Array.new

			# #t2 = Time.now.to_f
			# #timers << "t2-t1: " + (t2-t1).to_s


			# empty_companies_ids = Company.where(active: true, :owned => false).pluck(:id)
			# empty_elegible_locations = Location.where(:active => true).where(company_id: empty_companies_ids).where(id: ServiceProvider.where(active: true, company_id: empty_companies_ids).joins(:provider_times).joins(:services).where("services.id" => Service.where(active: true, company_id: empty_companies_ids).pluck(:id)).pluck(:location_id).uniq).joins(:location_times).uniq.order(order: :asc)
			# empty_locations = empty_elegible_locations.where('sqrt((latitude - ' + lat.to_s + ')^2 + (longitude - ' + long.to_s + ')^2) < 0.25')

			#names = locations.pluck('name')
			#empty_names = empty_locations.pluck('name')

			#t3 = Time.now.to_f
			#timers << "t3-t2: " + (t2-t2).to_s

			#Struct.new("Local", :id, :dist)

			# m1 = JaroWinkler.new(normalized_search)
			# m2 = PairDistance.new(normalized_search)

			# #t4 = Time.now.to_f
			# #timers << "t4-t3: " + (t4-t3).to_s

			# #Active companies' locations
			# locations.each do |location|

			# 	economic_sectors = location.company.economic_sectors
			# 	categories = location.categories
			# 	services = Array.new
			# 	service_providers = location.service_providers.where(active: true)



				#t5 = Time.now.to_f
				#timers << "t5-t4: " + (t5-t4).to_s

			# 	#Empresa

			# 	company_max = 0

			# 	str_test_array = location.company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s.split(' ')

			# 	test_array = Array.new

			# 	limit = str_test_array.count
			# 	if limit>4
			# 		limit = 4
			# 	end

			# 	for i in 0..limit
			# 	 	str_test_array.permutation(i).to_a.each do |perm|
			# 	 		test_array.push(perm)
			# 		end
			# 	end

			# 	#t6 = Time.now.to_f
			# 	#timers << "t6-t5: " + (t6-t5).to_s


			# 	test_array.each do |ta|

			# 	 	comScore1 = m1.match(ta.join(" "))
			# 	 	comScore2 = m2.match(ta.join(" "))

			# 	 	if(comScore1>company_max)
			# 	 		company_max = comScore1
			# 	 	end
			# 	 	if(comScore2>company_max)
			# 	 		company_max = comScore2
			# 	 	end

			# 	end

			# 	#t7 = Time.now.to_f
			# 	#timers << "t7-t6: " + (t7-t6).to_s


			# 	#Sectores económicos
			# 	ecoScore1 = 0
			# 	ecoScore2 = 0

			# 	economic_sectors.each do |sector|
			# 		score1 = m1.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > ecoScore1)
			# 			ecoScore1 = score1
			# 		end
			# 		if(score2 > ecoScore2)
			# 			ecoScore2 = score2
			# 		end
			# 	end


			# 	economics_max = ecoScore1
			# 	if(ecoScore2>economics_max)
			# 		economics_max = ecoScore2
			# 	end

			# 	#t8 = Time.now.to_f
			# 	#timers << "t8-t7: " + (t8-t7).to_s


			# 	#Categorías

			# 	catScore1 = 0
			# 	catScore2 = 0

			# 	categories.each do |category|
			# 		#Obtenemos los servicios de una categoría
			# 		services = services + category.services

			# 		score1 = m1.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > catScore1)
			# 			catScore1 = score1
			# 		end
			# 		if(score2 > catScore2)
			# 			catScore2 = score2
			# 		end

			# 	end

			# 	categories_max = catScore1
			# 	if(catScore2>categories_max)
			# 		categories_max = catScore2
			# 	end

			# 	#t9 = Time.now.to_f
			# 	#timers << "t9-t8: " + (t9-t8).to_s

			# 	#Servicios
			# 	servScore1 = 0
			# 	servScore2 = 0

			# 	services.each do |service|

			# 		score1 = m1.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > servScore1)
			# 			servScore1 = score1
			# 		end
			# 		if(score2 > servScore2)
			# 			servScore2 = score2
			# 		end

			# 	end

			# 	services_max = servScore1
			# 	if(servScore2>services_max)
			# 		services_max = servScore2
			# 	end

			# 	#t10 = Time.now.to_f
			# 	#timers << "t10-t9: " + (t10-t9).to_s

			# 	#Proveedores

			# 	provScore1 = 0
			# 	provScore2 = 0

			# 	service_providers.each do |provider|

			# 		score1 = m1.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > provScore1)
			# 			provScore1 = score1
			# 		end
			# 		if(score2 > provScore2)
			# 			provScore2 = score2
			# 		end

			# 	end



			# 	providers_max = provScore1
			# 	if(provScore2 > providers_max)
			# 		providers_max = provScore2
			# 	end


			# 	#t11 = Time.now.to_f
			# 	#timers << "t11-t10: " + (t11-t10).to_s

			# 	#Máximo
			# 	max = economics_max
			# 	if(categories_max>max)
			# 		max = categories_max
			# 	end
			# 	if(services_max>max)
			# 		max = services_max
			# 	end
			# 	if(company_max>max)
			# 		max = company_max
			# 	end
			# 	if(providers_max > max)
			# 		max = providers_max
			# 	end

			# 	#Segmentamos por puntaje, guardando las distancias

			# 	#t12 = Time.now.to_f
			# 	#timers << "t12-t11: " + (t12-t11).to_s

			# 	for i in 0..7
			# 		if((max >= (0.96 - i*0.04)))

			# 			#Calculamos la distancia aproximada

			# 			dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)

			# 			#Si la distancia es mayor que el máximo por tramos, NO agregamos el local
			# 			if i > 5
			# 				if dist_score > 0.10
			# 					break
			# 				end
			# 			elsif i > 3
			# 				if dist_score > 0.175
			# 					break
			# 				end
			# 			else
			# 				if dist_score > 0.25
			# 					break
			# 				end
			# 			end

			# 			#Guardamos el local con su distancia
			# 			local = [location, dist_score]
			# 			loc_segments[i].push(local)

			# 			break
			# 		end
			# 	end

			# 	#t13 = Time.now.to_f
			# 	#timers << "t13-t12: " + (t13-t12).to_s

			# end




			# m1 = JaroWinkler.new(normalized_search)
			# m2 = PairDistance.new(normalized_search)

			# #Empty companies' locations
			# empty_locations.each do |location|

			# 	economic_sectors = location.company.economic_sectors
			# 	categories = location.categories
			# 	services = Array.new
			# 	service_providers = location.service_providers.where(active: true)


			# 	#Empresa

			# 	empty_company_max = 0

			# 	str_test_array = location.company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s.split(' ')

			# 	test_array = Array.new

			# 	limit = str_test_array.count
			# 	if limit>4
			# 		limit = 4
			# 	end

			# 	for i in 0..limit
			# 	 	str_test_array.permutation(i).to_a.each do |perm|
			# 	 		test_array.push(perm)
			# 		end
			# 	end



			# 	test_array.each do |ta|

			# 	 	comScore1 = m1.match(ta.join(" "))
			# 	 	comScore2 = m2.match(ta.join(" "))

			# 	 	if(comScore1>empty_company_max)
			# 	 		empty_company_max = comScore1
			# 	 	end
			# 	 	if(comScore2>empty_company_max)
			# 	 		empty_company_max = comScore2
			# 	 	end

			# 	end


			# 	#Sectores económicos
			# 	ecoScore1 = 0
			# 	ecoScore2 = 0

			# 	economic_sectors.each do |sector|
			# 		score1 = m1.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > ecoScore1)
			# 			ecoScore1 = score1
			# 		end
			# 		if(score2 > ecoScore2)
			# 			ecoScore2 = score2
			# 		end
			# 	end

			# 	empty_economics_max = ecoScore1
			# 	if(ecoScore2>empty_economics_max)
			# 		empty_economics_max = ecoScore2
			# 	end


			# 	#Categorías

			# 	catScore1 = 0
			# 	catScore2 = 0

			# 	categories.each do |category|
			# 		#Obtenemos los servicios de una categoría
			# 		services = services + category.services

			# 		score1 = m1.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > catScore1)
			# 			catScore1 = score1
			# 		end
			# 		if(score2 > catScore2)
			# 			catScore2 = score2
			# 		end

			# 	end

			# 	empty_categories_max = catScore1
			# 	if(catScore2>empty_categories_max)
			# 		empty_categories_max = catScore2
			# 	end

			# 	#Servicios
			# 	servScore1 = 0
			# 	servScore2 = 0

			# 	services.each do |service|

			# 		score1 = m1.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > servScore1)
			# 			servScore1 = score1
			# 		end
			# 		if(score2 > servScore2)
			# 			servScore2 = score2
			# 		end

			# 	end

			# 	empty_services_max = servScore1
			# 	if(servScore2>empty_services_max)
			# 		empty_services_max = servScore2
			# 	end


			# 	#Proveedores

			# 	provScore1 = 0
			# 	provScore2 = 0

			# 	service_providers.each do |provider|

			# 		score1 = m1.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		score2 = m2.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').downcase.to_s)
			# 		if(score1 > provScore1)
			# 			provScore1 = score1
			# 		end
			# 		if(score2 > provScore2)
			# 			provScore2 = score2
			# 		end

			# 	end

			# 	empty_providers_max = provScore1
			# 	if(provScore2 > empty_providers_max)
			# 		empty_providers_max = provScore2
			# 	end



			# 	#Máximo
			# 	empty_max = empty_economics_max
			# 	if(empty_categories_max>empty_max)
			# 		empty_empty_max = empty_categories_max
			# 	end
			# 	if(empty_services_max>empty_max)
			# 		empty_max = empty_services_max
			# 	end
			# 	if(empty_company_max>empty_max)
			# 		empty_max = empty_company_max
			# 	end
			# 	if(empty_providers_max > empty_max)
			# 		empty_max = empty_providers_max
			# 	end

			# 	#Segmentamos por puntaje, guardando las distancias

			# 	for i in 0..7
			# 		if((empty_max >= (0.96 - i*0.04)))

			# 			#Calculamos la distancia aproximada

			# 			dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)

			# 			#Si la distancia es mayor que el máximo por tramos, NO agregamos el local
			# 			if i > 5
			# 				if dist_score > 0.10
			# 					break
			# 				end
			# 			elsif i > 3
			# 				if dist_score > 0.175
			# 					break
			# 				end
			# 			else
			# 				if dist_score > 0.25
			# 					break
			# 				end
			# 			end

			# 			#Guardamos el local con su distancia
			# 			local = [location, dist_score]
			# 			empty_loc_segments[i].push(local)

			# 			break
			# 		end
			# 	end

			# end


			#t14 = Time.now.to_f


			#Ordenamos por distancia
			ordered_segments = Array.new
			for i in 0..7
				ordered_segments[i] = loc_segments[i].sort_by{ |loc| loc[1]}
			end


			#Ordenamos por distancia
			empty_ordered_segments = Array.new
			for i in 0..7
				empty_ordered_segments[i] = empty_loc_segments[i].sort_by{ |loc| loc[1]}
			end


			#Entregamos los ids en orden
			for i in 0..7
				segment = ordered_segments[i]
				segment.each do |s|
					#loc_ids.push(s[0])
					@results << s[0]
				end
			end


			#Entregamos los ids en orden
			for i in 0..7
				empty_segment = empty_ordered_segments[i]
				empty_segment.each do |s|
					#loc_ids.push(s[0])
					@results << s[0]
				end
			end

			per_page = 10

			@results = @results.paginate(:page => params[:page], :per_page => per_page)


			i = 1
			for i in 1..per_page
				if !File.exist?("app/assets/images/search/pin_map#{i}.png")
					img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
					if i<10
						img.combine_options do |c|
					    	c.draw "text 9,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					elsif i<100
						img.combine_options do |c|
					    	c.draw "text 4,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					else
						img.combine_options do |c|
					    	c.draw "text 1,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					end

					img.write("app/assets/images/search/pin_map#{i}.png")
				end
			end


			respond_to do |format|
				format.html
				format.json { render :json => @results }
			end
		else
			redirect_to root_path
		end
	end


	def promotions


			@lat = "-33.4052419"
			@lng = "-70.597557"
			@formatted_address = "Santiago, Región Metropolitana, Chile"

			if Country.find_by(locale: I18n.locale.to_s)
				@country = Country.find_by(locale: I18n.locale.to_s)
				@lat = @country.latitude
				@lng = @country.longitude
				@formatted_address = @country.formatted_address
			end

			if params[:latitude] &&  params[:latitude] != ""
				@lat = params[:latitude]
			end
			if params[:longitude] && params[:longitude] != ""
				@lng = params[:longitude]
			end


			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			end
			# => Domain parser
			#host = request.host_with_port
			#@domain = host[host.index(request.domain)..host.length]


			lat = @lat
			long = @lng

			@latitude = @lat
			@longitude = @lng

			@results = Array.new
			@empty_results = Array.new

			@economic_sector_selected = 0

			normalized_search = ""

			@inputSearch = params[:inputSearch]

			if params[:inputSearch] && params[:inputSearch] != ""

				search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

				normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

			elsif params[:economicSector] && params[:economicSector] != "" && params[:economicSector] != "0" && params[:economicSector] != 0

				economic_sector = EconomicSector.find(params[:economicSector])
				search = economic_sector.name.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

				normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

				@economic_sector_selected = economic_sector.id

			end

			logger.debug "EcoSec: " + normalized_search

			# First, search services with promotions based on time of book (morning, afternoon, night)

			if normalized_search != ""

				time_query = Location.search_services(normalized_search).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')

			else

				time_query = Location.where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')


			end

			query = time_query

			logger.debug "Query array"
			logger.debug query.inspect

			locs = Array.new
			ordered_locs = Array.new

			if normalized_search != ""
				if query.count > 10

					count = (query.count.to_f / 10).ceil
					results = Array.new

					current_rank = query[0].pg_search_rank
					current_group = Array.new
					query.each do |res|
						if res.pg_search_rank <= current_rank && (res.pg_search_rank - current_rank).abs < 0.015
							current_group << res
						else
							results << current_group
							current_group = Array.new
							current_group << res
							current_rank = res.pg_search_rank
						end
					end
					results << current_group

					j = 0
					results.each do |result|
						locs[j] = Array.new
						result.each do |location|
							dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
							local = [location, dist_score]
							locs[j].push(local)
						end
						j = j+1
					end

					for i in 0..j-1
						ordered_locs[i] = locs[i].sort_by{ |loc| loc[1]}
					end

				else
					query.each do |location|
						dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
						local = [location, dist_score]
						locs.push(local)
					end
					ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
				end
			else
				query.each do |location|
					dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
					local = [location, dist_score]
					locs.push(local)
				end
				ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
			end

			logger.debug "Ordered_locs"
			logger.debug ordered_locs.inspect

			@results = Array.new
			@locations = Array.new
			@last_minute_results = Array.new

			ordered_locs.each do |arr|
				arr.each do |s|

					time_promo_services = []

					ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
						logger.debug "Provider: " + service_provider.public_name
						if normalized_search != ""
							time_promo_services = service_provider.services.with_time_promotions.search(normalized_search)
						else
							time_promo_services = service_provider.services.with_time_promotions
						end

						time_promo_services.each do |service|
							#Check it has stock
							if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
								if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
									promo_detail = [service, s[0]]
									if !@results.include?(promo_detail)
										@results << promo_detail
										#if !@locations.include?(s[0])
										@locations << s[0]
									end
								end
							end
						end

						logger.debug time_promo_services.inspect

					end


				end
			end

			per_page = 9

			@results = @results.paginate(:page => params[:page], :per_page => per_page)

			i = 1
			for i in 1..per_page
				if !File.exist?("app/assets/images/search/pin_map#{i}.png")
					img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
					if i<10
						img.combine_options do |c|
					    	c.draw "text 9,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					elsif i<100
						img.combine_options do |c|
					    	c.draw "text 4,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					else
						img.combine_options do |c|
					    	c.draw "text 1,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					end

					img.write("app/assets/images/search/pin_map#{i}.png")
				end
			end




			if normalized_search != ""

				last_minute_query = Location.search_services(normalized_search).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')

			else

				last_minute_query = Location.where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')


			end


			########################
			## LAST MINUTE PROMOS ##
			########################s

			last_minute_locs = Array.new
			last_minute_ordered_locs = Array.new


			@last_minute_results = Array.new
			@last_minute_locations = Array.new

			last_minute_ordered_locs.each do |arr|
				arr.each do |s|

					last_minute_services = []

					ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
						if normalized_search != ""
							last_minute_services = service_provider.services.with_last_minute_promotions.search(normalized_search)
						else
							last_minute_services = service_provider.services.with_last_minute_promotions
						end

						last_minute_services.each do |service|
							if !@last_minute_results.include?(service)
								promo_detail = [service, s[0]]
								@last_minute_results << promo_detail
								#if !@locations.include?(s[0])
								@last_minute_locations << s[0]
								#end
							end
						end

					end

				end
			end

			respond_to do |format|
				format.html
			end


	end

	def last_minute_promotions

		@lat = "-33.4052419"
		@lng = "-70.597557"

		if params[:latitude] &&  params[:latitude] != ""
			@lat = params[:latitude]
		end
		if params[:longitude] && params[:longitude] != ""
			@lng = params[:longitude]
		end


		if cookies[:formatted_address]
			@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		end
		# => Domain parser
		host = request.host_with_port
		@domain = host[host.index(request.domain)..host.length]


		lat = @lat
		long = @lng

		@latitude = @lat
		@longitude = @lng

		@results = Array.new
		@empty_results = Array.new

		@economic_sector_selected = 0

		normalized_search = ""

		@inputSearch = params[:inputSearch]

		if params[:inputSearch] && params[:inputSearch] != ""

			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

		elsif params[:economicSector] && params[:economicSector] != "" && params[:economicSector] != "0" && params[:economicSector] != 0

			economic_sector = EconomicSector.find(params[:economicSector])
			search = economic_sector.name.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

			@economic_sector_selected = economic_sector.id

		end

		if normalized_search != ""

				query = Location.search_services(normalized_search).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')

			else

				query = Location.where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')


			end

			locs = Array.new
			ordered_locs = Array.new

			if normalized_search != ""
				if query.count > 10

					count = (query.count.to_f / 10).ceil
					results = Array.new

					current_rank = query[0].pg_search_rank
					current_group = Array.new
					query.each do |res|
						if res.pg_search_rank <= current_rank && (res.pg_search_rank - current_rank).abs < 0.015
							current_group << res
						else
							results << current_group
							current_group = Array.new
							current_group << res
							current_rank = res.pg_search_rank
						end
					end
					results << current_group

					j = 0
					results.each do |result|
						locs[j] = Array.new
						result.each do |location|
							dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
							local = [location, dist_score]
							locs[j].push(local)
						end
						j = j+1
					end

					for i in 0..j-1
						ordered_locs[i] = locs[i].sort_by{ |loc| loc[1]}
					end

				else
					query.each do |location|
						dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
						local = [location, dist_score]
						locs.push(local)
					end
					ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
				end
			else
				query.each do |location|
					dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
					local = [location, dist_score]
					locs.push(local)
				end
				ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
			end

			@results = Array.new
			@locations = Array.new
			@last_minute_results = Array.new

			ordered_locs.each do |arr|
				arr.each do |s|

					last_minute_services = []

					ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
						if normalized_search != ""
							last_minute_services = service_provider.services.with_last_minute_promotions.search(normalized_search)
						else
							last_minute_services = service_provider.services.with_last_minute_promotions
						end
					end

					last_minute_services.each do |service|
						#if !@results.include?(service)
							promo_detail = [service, s[0]]
							@results << promo_detail
							#if !@locations.include?(s[0])
							@locations << s[0]
							#end
						#end
					end
				end
			end


			per_page = 9

			@results = @results.paginate(:page => params[:page], :per_page => per_page)

			i = 1
			for i in 1..per_page
				if !File.exist?("app/assets/images/search/pin_map#{i}.png")
					img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
					if i<10
						img.combine_options do |c|
					    	c.draw "text 9,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					elsif i<100
						img.combine_options do |c|
					    	c.draw "text 4,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					else
						img.combine_options do |c|
					    	c.draw "text 1,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					end

					img.write("app/assets/images/search/pin_map#{i}.png")
				end
			end


			respond_to do |format|
				format.html
			end

	end


	def treatment_promotions

			@lat = "-33.4052419"
			@lng = "-70.597557"
			@formatted_address = "Santiago, Región Metropolitana, Chile"

			if Country.find_by(locale: I18n.locale.to_s)
				@country = Country.find_by(locale: I18n.locale.to_s)
				@lat = @country.latitude
				@lng = @country.longitude
				@formatted_address = @country.formatted_address
			end

			if params[:latitude] &&  params[:latitude] != ""
				@lat = params[:latitude]
			end
			if params[:longitude] && params[:longitude] != ""
				@lng = params[:longitude]
			end


			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			end
			# => Domain parser
			#host = request.host_with_port
			#@domain = host[host.index(request.domain)..host.length]


			lat = @lat
			long = @lng

			@latitude = @lat
			@longitude = @lng

			@results = Array.new
			@empty_results = Array.new

			@economic_sector_selected = 0

			normalized_search = ""

			if params[:inputSearch] && params[:inputSearch] != ""

				search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

				normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

			elsif params[:economicSector] && params[:economicSector] != "" && params[:economicSector] != "0" && params[:economicSector] != 0

				economic_sector = EconomicSector.find(params[:economicSector])
				search = economic_sector.name.gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

				normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/,'').downcase.to_s

				@economic_sector_selected = economic_sector.id

			end

			# First, search services with promotions based on time of book (morning, afternoon, night)

			if normalized_search != ""

				treatment_query = Location.search_services(normalized_search).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')

			else

				treatment_query = Location.where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true, id: PromoTime.where(:active => true).pluck(:company_setting_id)).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25')


			end

			query = treatment_query

			logger.debug "Query array"
			logger.debug query.inspect

			locs = Array.new
			ordered_locs = Array.new

			if normalized_search != ""
				if query.count > 10

					count = (query.count.to_f / 10).ceil
					results = Array.new

					current_rank = query[0].pg_search_rank
					current_group = Array.new
					query.each do |res|
						if res.pg_search_rank <= current_rank && (res.pg_search_rank - current_rank).abs < 0.015
							current_group << res
						else
							results << current_group
							current_group = Array.new
							current_group << res
							current_rank = res.pg_search_rank
						end
					end
					results << current_group

					j = 0
					results.each do |result|
						locs[j] = Array.new
						result.each do |location|
							dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
							local = [location, dist_score]
							locs[j].push(local)
						end
						j = j+1
					end

					for i in 0..j-1
						ordered_locs[i] = locs[i].sort_by{ |loc| loc[1]}
					end

				else
					query.each do |location|
						dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
						local = [location, dist_score]
						locs.push(local)
					end
					ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
				end
			else
				query.each do |location|
					dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
					local = [location, dist_score]
					locs.push(local)
				end
				ordered_locs[0] = locs.sort_by{ |loc| loc[1]}
			end

			logger.debug "Ordered_locs"
			logger.debug ordered_locs.inspect

			@results = Array.new
			@locations = Array.new
			@last_minute_results = Array.new

			ordered_locs.each do |arr|
				arr.each do |s|

					treatment_promo_services = []

					ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
						logger.debug "Provider: " + service_provider.public_name
						if normalized_search != ""
							treatment_promo_services = service_provider.services.with_treatment_promotions.search(normalized_search)
						else
							treatment_promo_services = service_provider.services.with_treatment_promotions
						end

						treatment_promo_services.each do |service|
							#Check it has stock
							if service.active_treatment_promo.max_bookings > 0 || !service.active_treatment_promo.limit_booking
								if DateTime.now < service.active_treatment_promo.finish_date
									promo_detail = [service, s[0]]
									if !@results.include?(promo_detail)
										@results << promo_detail
										#if !@locations.include?(s[0])
										@locations << s[0]
									end
								end
							end
						end

						logger.debug treatment_promo_services.inspect

					end


				end
			end

			per_page = 9

			@results = @results.paginate(:page => params[:page], :per_page => per_page)

			i = 1
			for i in 1..per_page
				if !File.exist?("app/assets/images/search/pin_map#{i}.png")
					img = MiniMagick::Image.from_file("app/assets/images/search/pin_map.png")
					if i<10
						img.combine_options do |c|
					    	c.draw "text 9,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					elsif i<100
						img.combine_options do |c|
					    	c.draw "text 4,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					else
						img.combine_options do |c|
					    	c.draw "text 1,22 '#{i.to_s}'"
							c.fill("#FFFFFF")
							c.pointsize "17"
						end
					end

					img.write("app/assets/images/search/pin_map#{i}.png")
				end
			end

			respond_to do |format|
				format.html
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
