class LocationOpenDay < ActiveRecord::Base
  belongs_to :location

  after_update :fix_provider_open_days
  after_destroy :destroy_provider_open_days

  validate :day_opened, :time_limits

  def day_opened
    if LocationOpenDay.where(location_id: self.location_id, start_time: self.start_time.beginning_of_day..self.start_time.end_of_day).where.not(id: self.id).count > 0
      errors.add(:base, "Ya existe una apertura horaria para este día.")
    end
  end

  def time_limits
    start_time = self.location.company.company_setting.extended_min_hour         
    end_time = self.location.company.company_setting.extended_max_hour
    
    #If calendar isn't extended, then get the largest location_time
    if !self.location.company.company_setting.extended_schedule_bool
      open_time = self.location.location_times.order(open: :asc).first.open
      close_time = self.location.location_times.order(close: :desc).first.close
      start_time = open_time.change(year: self.start_time.year, month: self.start_time.month, day: self.start_time.day, offset: "+0000")
      end_time = close_time.change(year: self.start_time.year, month: self.start_time.month, day: self.start_time.day, offset: "+0000")
    end

    if self.start_time < start_time || self.end_time > end_time
      errors.add(:base, "El horario elegido sobrepasa los límites horarios del local. Puedes extender el límite horario en las configuraciones de tu empresa.")
    end

  end

  def fix_provider_open_days
    start_limit = self.start_time
    end_limit = self.end_time
    if LocationTime.where(location_id: self.location_id, day_id: self.start_time.to_datetime.cwday).count > 0
      LocationTime.where(location_id: self.location_id, day_id: self.start_time.to_datetime.cwday).each do |location_time|
        location_time_start = DateTime.new(self.start_time.year, self.start_time.month, self.start_time.day, location_time.open.hour, location_time.open.min)
        location_time_end = DateTime.new(self.start_time.year, self.start_time.month, self.start_time.day, location_time.close.hour, location_time.close.min)
        if location_time_start < start_limit
          start_limit = location_time_start
        end
        if location_time_end > end_limit
          end_limit = location_time_end
        end
      end
    end
  	ProviderOpenDay.where(service_provider_id: ServiceProvider.where(location_id: self.location_id).pluck(:id), start_time: self.start_time.beginning_of_day..self.start_time.end_of_day).each do |provider_open_day|
  		provider_open_day.adjust(start_limit, end_limit)
  	end
  end

  def destroy_provider_open_days
    location_time = self.location.location_times.where(day_id: self.start_time.to_datetime.cwday).first
    if location_time.nil?
  	 ProviderOpenDay.where(service_provider_id: ServiceProvider.where(location_id: self.location_id).pluck(:id), start_time: self.start_time.beginning_of_day..self.start_time.end_of_day).destroy_all
    else
      location_time.fix_provider_open_days
    end
  end

end
