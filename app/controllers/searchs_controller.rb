class SearchsController < ApplicationController
	layout "results", except: [:index]
	require 'amatch'
	include Amatch

	def index
		@lat = cookies[:lat].to_f
		@lng = cookies[:lng].to_f
		if cookies[:formatted_address]
			@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
		end
		render layout: "search"
	end
	  
	def search
		if params[:inputSearch] && params[:latitude] && params[:longitude] && params[:inputLocalization]
			@lat = cookies[:lat].to_f
			@lng = cookies[:lng].to_f

			

			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			end
			# => Domain parser
			host = request.host_with_port
			@domain = host[host.index(request.domain)..host.length]

			if(!@lat)
				lat = params[:latitude]
			else
				lat = @lat
			end
			if(!@long)
				long = params[:longitude]
			else
				long = @long
			end

			lat = @lat
			long = @lng



			@latitude = @lat
			@longitude = @lng

			

			#Filtrado de pronombres y artículos
			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%')

			normalized_search = search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s

			#Segmentos de locales según resultados
			loc_segments = Array.new
			two_score_segments = Array.new

			for i in 0..7
				loc_segments[i] = Array.new
			end

			locations_scores = Hash.new

			locations = Location.all
			loc_ids = Array.new

			Struct.new("Local", :id, :dist)

			locations.each do |location|

				economic_sectors = location.company.economic_sectors
				categories = location.categories
				services = Array.new
				service_providers = location.service_providers


				m1 = JaroWinkler.new(normalized_search)
				m2 = PairDistance.new(normalized_search)


				#Empresa

				comScore1 = m1.match(location.company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
				comScore2 = m2.match(location.company.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)

				company_max = comScore1

				if(comScore2>company_max)
					company_max = comScore2
				end


				#Sectores económicos
				ecoScore1 = 0
				ecoScore2 = 0

				economic_sectors.each do |sector|
					score1 = m1.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					score2 = m2.match(sector.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					if(score1 > ecoScore1)
						ecoScore1 = score1
					end
					if(score2 > ecoScore2)
						ecoScore2 = score2
					end
				end

				economics_max = ecoScore1
				if(ecoScore2>economics_max)
					economics_max = ecoScore2
				end


				#Categorías

				catScore1 = 0
				catScore2 = 0

				categories.each do |category|
					#Obtenemos los servicios de una categoría
					services = services + category.services

					score1 = m1.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					score2 = m2.match(category.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
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

				#Servicios
				servScore1 = 0
				servScore2 = 0

				services.each do |service|

					score1 = m1.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					score2 = m2.match(service.name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					if(score1 > servScore1)
						servScore1 = score1
					end
					if(score2 > servScore2)
						servScore2 = score2
					end

				end

				services_max = servScore1
				if(servScore2>services_max)
					services_max = servScore2
				end


				#Proveedores

				provScore1 = 0
				provScore2 = 0

				service_providers.each do |provider|

					score1 = m1.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					score2 = m2.match(provider.public_name.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
					if(score1 > provScore1)
						provScore1 = score1
					end
					if(score2 > provScore2)
						provScore2 = score2
					end

				end

				providers_max = provScore1
				if(provScore2 > providers_max)
					providers_max = provScore2
				end



				#Máximo
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

						#Guardamos la distancia
						local = Struct::Local.new(location.id, dist_score)
						loc_segments[i].push(local)

						#locations_scores[location.id] = "*** Total max: " + max.to_s + " / Distance: " + dist_score.to_s

						break
					end
				end
					
			end


			#Ordenamos por distancia
			ordered_segments = Array.new
			for i in 0..7
				ordered_segments[i] = loc_segments[i].sort_by{ |loc| loc[:dist]}
			end
					

			#Entregamos los ids en orden
			for i in 0..7
				segment = ordered_segments[i]
				segment.each do |s|
					loc_ids.push(s[:id])
				end
			end

			@results = Array.new

			#Los obtenemos en orden
			loc_ids.each do |lid|
				@results << Location.find(lid)
				#ordered_scores[lid] = locations_scores[lid]
			end

			

			#@results = Location.where("id IN (?)", loc_ids)
			@results = @results.paginate(:page => params[:page], :per_page => 10)

			i = 1
			@results.each do |location|
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

			Rails.logger.level = 3

			Rails.logger.error("Original: #{@lat} #{@lng}")
			Rails.logger.error("Second: #{lat} #{long}")
			Rails.logger.error("Third: #{@latitude} #{@longitude}")
			#@scores = ordered_scores

			respond_to do |format|
				format.html
				format.json { render :json => @results }
			end
		else
			redirect_to root_path
		end
	end

	def search_backup

		if params[:inputSearch] && params[:latitude] && params[:longitude] && params[:inputLocalization]
			@lat = cookies[:lat].to_f
			@lng = cookies[:lng].to_f
			if cookies[:formatted_address]
				@formatted_address = cookies[:formatted_address].encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
			end
			# => Domain parser
			host = request.host_with_port
			@domain = host[host.index(request.domain)..host.length]

			if(!@lat)
				lat = params[:latitude]
			else
				lat = @lat
			end
			if(!@long)
				long = params[:longitude]
			else
				long = @long
			end

			#Filtrado de pronombres y artículos
			search = params[:inputSearch].gsub(/\b([D|d]el?)+\b|\b([U|u]n(o|a)?s?)+\b|\b([E|e]l)+\b|\b([T|t]u)+\b|\b([L|l](o|a)s?)+\b|\b[AaYy]\b|["'.,;:-]|\b([E|e]n)+\b|\b([L|l]a)+\b|\b([C|c]on)+\b|\b([Q|q]ue)+\b|\b([S|s]us?)+\b|\b([E|e]s[o|a]?s?)+\b/i, '').gsub(/(\s)+/, '%')

			#Obtenemos los substrings de la consulta filtrada
			search_arr = search.split(" ")
			normalized_search = Array.new


			#for i in 0..search.count
			#	search.permutation(i).to_a.each do |str|
			#		str = str.join(" ")
			#		normalized_search.push(str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
			#	end
			#end

			#search_arr.each do |str|
				normalized_search.push(search.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s)
			#end

			#Segmentos de locales según resultados
			loc_segments = Array.new
			two_score_segments = Array.new
			# score > 0.95
			# score > 0.9
			# score > 0.85
			# .
			# .
			# .
			# score > 0.5 FIN

			for i in 0..9
				loc_segments[i] = Hash.new
				two_score_segments[i] = Hash.new
			end

			locations_scores = Hash.new
			locations_max = Hash.new
			locations_avgs = Hash.new
			locations_distances = Hash.new

			locations = Location.all
			loc_ids = Array.new

			locations.each do |location|

				economic_sectors = location.company.economic_sectors
				categories = location.categories
				services = Array.new

				#String de comparación
				company_name_arr = location.company.name.split(" ");


				#Scores de los distintos criterios
				company_score = 0
				company_max = 0

				economics_score = 0
				economics_max = 0

				categories_score = 0
				categories_max = 0

				services_score = 0
				services_max = 0

				compCount = 0
				#Obtenemos score de la empresa (nombre)
				normalized_search.each do |s|

					m = JaroWinkler.new(s)

					#Recorremos el arreglo del nombre de empresa
					company_name_arr.each do |cn|
						compCount = compCount+1
						cn = cn.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
						comp_score = m.match(cn)
						company_score = company_score + comp_score
						if(company_max < comp_score)
							company_max = comp_score
						end
					end
				end
				company_score = company_score/(compCount)

				esCount = 0
				#Obtenemos score de sectores económicos
				normalized_search.each do |s|

					m = JaroWinkler.new(s)

					#Recorremos los sectores
					economic_sectors.each do |sector|

						#Recorremos el arreglo de nombre para cada sector
						sector_arr = sector.name.split(" ")

						sector_arr.each do |sn|
							esCount = esCount+1
							sn = sn.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
							eco_score = m.match(sn)
							economics_score = economics_score+eco_score
							if(economics_max < eco_score)
								economics_max = eco_score
							end
						end

					end
					
				end
				economics_score = economics_score/(esCount)

				catCount = 0
				#Score de las categorías
				normalized_search.each do |s|

					m = JaroWinkler.new(s)

					categories.each do |category|

						category_arr = category.name.split(" ")

						category_arr.each do |cn|
							catCount = catCount+1
							cn = cn.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
							cat_score = m.match(cn)
							categories_score = categories_score + cat_score

							if (categories_max < cat_score)
								categories_max = cat_score
							end
						end

						#Obtenemos los servicios de una categoría
						services = services + category.services
					end
					
				end
				categories_score = categories_score/(catCount)

				servCount = 0
				#Score de los servicios
				normalized_search.each do |s|

					m = JaroWinkler.new(s)

					services.each do |service|

						service_arr = service.name.split(" ")

						service_arr.each do |sn|
							servCount = servCount+1
							sn = sn.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
							serv_score = m.match(sn)
							services_score = services_score + serv_score
							if(services_max < serv_score)
								services_max = serv_score
							end
						end
					end

				end
				services_score = services_score/(servCount)

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

				#Fórmula con scores promedio
				avg_score = company_score*0.25 + economics_score*0.25 + categories_score*0.25 + services_score*0.25

				#Fórmula con max scores
				max_score = company_max*0.25 + economics_max*0.25 + categories_max*0.25 + services_max*0.25

				#Fórmula usando sólo los dos mayores
				two_max_score = 0
				loc_score = [company_max, economics_max, categories_max, services_max]
				loc_score.sort
				two_max_score = (loc_score[2]+loc_score[3])/2

				
				locations_avgs[location.id] = avg_score
				locations_max[location.id] = max_score

				#Distance score
				dist_score = Math.sqrt((location.latitude - lat.to_f)**2 + (location.longitude - long.to_f)**2)
				locations_distances[location.id] = dist_score

				locations_scores[location.id] = " / Two score: " + two_max_score.to_s + " / Total max: " + max.to_s + " / Avg score: " + avg_score.to_s + " / Max score: " + max_score.to_s + " / Distance: " + dist_score.to_s + " / EcoSector: " + location.company.economic_sectors[0].name

				#ecoSectorCoef = economic_sectors.count / EconomicSector.count
				#catCoef = categories.count / ServiceCategory.count
				#servCoef = services.count / Service.count

				#Segmentamos por puntaje, guardando las distancias

				for i in 0..9
					if((max >= (0.95 - i*0.04)))
						loc_segments[i][location.id] = dist_score
						two_score_segments[i][location.id] = two_max_score
						break
					end
				end
					

			end

			#Ordenamos por distancia
			for i in 0..9
				loc_segments[i].sort_by{ |k,v| v}
			end
					

			#Entregamos los ids en orden
			for i in 0..9
				puts "Segment " + i.to_s
				loc_segments[i].each do |k, v|
					loc_ids.push(k)
					puts (k)
				end
			end

			ordered_scores = Hash.new
			puts "Locations IDS:"

			@results = Array.new

			loc_ids.each do |lid|
				@results << Location.find(lid)
				ordered_scores[lid] = locations_scores[lid]
				puts lid.to_s
			end

			

			#@results = Location.where("id IN (?)", loc_ids)
			@results = @results.paginate(:page => params[:page], :per_page => 10)

			i = 1
			@results.each do |location|
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

			@scores = ordered_scores

			respond_to do |format|
				format.html
				format.json { render :json => @scores }
			end
		else
			redirect_to root_path
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
