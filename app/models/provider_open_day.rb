class ProviderOpenDay < ActiveRecord::Base
  belongs_to :service_provider

  validate :location_open

  def location_open
  	
  	if !self.service_provider.location.is_open(self.start_time, self.end_time)
  		errors.add(:base, "El horario ingresado no se ajusta al horario del local.")
  	end

  end

  def adjust(start_limit, end_limit)
    puts "Adjust with #{start_limit} and #{end_limit}"
  	if start_limit > self.start_time
  		self.start_time = start_limit
  	end
  	if end_limit < self.end_time
  		self.end_time = end_limit
  	end
    if self.start_time < self.end_time
  	 self.save
    else
      self.destroy
    end
  end

end
