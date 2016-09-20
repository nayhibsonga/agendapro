class PromoTime < ActiveRecord::Base
	belongs_to :company_setting

	validate :times_overlaps


	def times_overlaps
		if (self.morning_start > self.morning_end) || (self.afternoon_start > self.afternoon_end) || (self.night_start > self.night_end)
			errors.add(:base, "El horario de término de un bloque no puede ser menor que el de inicio.")
		end
		if (self.morning_end > self.afternoon_start) || (self.afternoon_end > self.night_start)
			errors.add(:base, "Un bloque horario no puede traslaparse con otro.")
		end
	end

end
