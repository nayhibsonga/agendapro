module Api
	module CustomApp
  module V1
  	class LocationsController < V1Controller
      def index
      	@lat = "-33.4052419"
				@lng = "-70.597557"

				if params[:latitude] &&  params[:latitude] != ""
					@lat = params[:latitude]
				end
				if params[:longitude] && params[:longitude] != ""
					@lng = params[:longitude]
				end

				lat = @lat
				long = @lng

				@latitude = @lat
				@longitude = @lng

				@results = Array.new
      	@locations = Location.where(company_id: @api_company.id, online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_workflow => true).pluck('company_id'))).where(:active => true).select('locations.*, sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2)').order('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2)')

				# First, search services with promotions based on time of book (morning, afternoon, night)

				time_query = @locations

				query = time_query

				locs = Array.new
				ordered_locs = Array.new
				query.each do |location|
					dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
					local = [location, dist_score]
					locs.push(local)
				end
				ordered_locs[0] = locs.sort_by{ |loc| loc[1]}

				@results = Array.new
				@locations2 = Array.new
				@last_minute_results = Array.new

				ordered_locs.each do |arr|
					arr.each do |s|

						time_promo_services = []

						ServiceProvider.where(:active => true, :location_id => s[0]).each do |service_provider|
							time_promo_services = service_provider.services.with_time_promotions

							time_promo_services.each do |service|
								#Check it has stock
								if service.active_service_promo.max_bookings > 0 || !service.active_service_promo.limit_booking
									if DateTime.now < service.active_service_promo.finish_date && DateTime.now < service.active_service_promo.book_limit_date
										promo_detail = [service, s[0]]
										if !@results.include?(promo_detail)
											@results << promo_detail
											#if !@locations2.include?(s[0])
											@locations2 << s[0]
										end
									end
								end
							end
						end
					end
				end
				@app_feeds = @api_company.app_feeds
      end

      def show
      	@location = Location.find(params[:id])
      end

      def favorite
      	@location = Location.find(params[:id])
      	unless @mobile_user.favorite_locations.exists?(id: @location)
			if Favorite.create(user: @mobile_user, location: @location)
				render json: { favorite: true }, status: 200
			else
				render json: { favorite: false }, status: 422
			end
		else
			@favorite = Favorite.where(location: @location, user: @mobile_user).first
		    if @favorite.destroy
		    	render json: { favorite: false }, status: 200
		    else
		    	render json: { favorite: true }, status: 422
		    end
		end
      end

      def search
      	if (params[:search_text].present? || params[:economic_sector_id].present?) && params[:latitude].present? && params[:longitude].present?

      		if params[:search_text].present?
	      		UserSearch.create(user_id: @mobile_user.id, search_text: params[:search_text])
	      	end

			@lat = params[:latitude]
			@lng = params[:longitude]


			lat = params[:latitude]
			long = params[:longitude]

			@latitude = params[:latitude]
			@longitude = params[:longitude]
      		if params[:search_text].present?

				@results = Array.new
					#@empty_results = Array.new

					search = params[:search_text].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '')

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
						if Location.find(result['location_id'])
							@results << Location.find(result['location_id'])
						end
					end

			elsif params[:economic_sector_id].present?
				@results = Location.where(company_id: CompanyEconomicSector.where(economic_sector_id: params[:economic_sector_id]).pluck(:company_id)).where(online_booking: true, id: ServiceProvider.where(active: true, online_booking: true, id: ServiceStaff.where(service_id: Service.where(online_booking: true, active: true)).pluck(:service_provider_id)).pluck('location_id')).where(company_id: Company.where(:active => true, :owned => true).where(id: CompanySetting.where(:activate_search => true, :activate_workflow => true).pluck('company_id'))).where(:active => true).where('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2) < 0.25').select('locations.*, sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2)').order('sqrt((latitude - ' + @latitude.to_s + ')^2 + (longitude - ' + @longitude.to_s + ')^2)')
			else
				render json: { error: 'Invalid Request. Missing Param(s)' }, status: 500
			end

			per_page = 10

			# @results = @results.paginate(:page => params[:page], :per_page => per_page)

		else
			render json: { error: 'Invalid Request. Missing Param(s)' }, status: 500
		end
      end
  	end
  end
end
end
