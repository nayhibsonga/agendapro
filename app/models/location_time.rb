class LocationTime < ActiveRecord::Base
	belongs_to :day
	belongs_to :location

	validates :open, :close, :presence => true

	after_save :fix_provider_open_days
	#before_destroy :destroy_provider_open_days

	def fix_provider_open_days
		day_id = self.day_id
		if day_id == 7
			day_id = 0
		end
		puts "Before search provider_open_days"
		ProviderOpenDay.where(service_provider_id: ServiceProvider.where(location_id: self.location_id).pluck(:id)).where('extract(dow from start_time) = ?', day_id).each do |provider_open_day|
			puts "Finds provider_open_days"
			#Check for location days. If found, adjust provider_open_day with max limits.
			start_limit = DateTime.new(provider_open_day.start_time.year, provider_open_day.start_time.month, provider_open_day.start_time.day, self.open.hour, self.open.min)
			end_limit = DateTime.new(provider_open_day.start_time.year, provider_open_day.start_time.month, provider_open_day.start_time.day, self.close.hour, self.close.min)
			LocationOpenDay.where(location_id: self.location_id).where('(location_open_days.start_time, location_open_days.end_time) OVERLAPS (?, ?)', provider_open_day.start_time, provider_open_day.end_time).each do |location_open_day|
				if location_open_day.start_time < start_limit
					start_limit = location_open_day.start_time
				end
				if location_open_day.end_time > end_limit
					end_limit = location_open_day.end_time
				end
			end
			provider_open_day.adjust(start_limit, end_limit)
		end
	end

	# def destroy_provider_open_days
	# 	day_id = self.day_id
	# 	if day_id == 7
	# 		day_id = 0
	# 	end
	# 	ProviderOpenDay.where(service_provider_id: ServiceProvider.where(location_id: self.location_id).pluck(:id)).where('extract(dow from start_time) = ?', day_id).each do |provider_open_day|

	# 		#If there's no open_day, destroy provider_open_day
	# 		if LocationOpenDay.where(location_id: self.location_id).where('(location_open_days.start_time, location_open_days.end_time) OVERLAPS (?, ?)', provider_open_day.start_time, provider_open_day.end_time).count == 0
	# 			provider_open_day.destroy
	# 		else
	# 			#Check for location days. If found, adjust provider_open_day with max limits.
	# 			start_limit = provider_open_day.start_time
	# 			end_limit = provider_open_day.end_time
	# 			LocationOpenDay.where(location_id: self.location_id).where('(location_open_days.start_time, location_open_days.end_time) OVERLAPS (?, ?)', provider_open_day.start_time, provider_open_day.end_time).each do |location_open_day|
	# 				if location_open_day.start_time < start_limit
	# 					start_limit = location_open_day.start_time
	# 				end
	# 				if location_open_day.end_time > end_limit
	# 					end_limit = location_open_day.end_time
	# 				end
	# 			end
	# 			provider_open_day.adjust(start_limit, end_limit)
	# 		end

	# 	end
	# end

end