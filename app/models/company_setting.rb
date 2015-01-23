class CompanySetting < ActiveRecord::Base
	belongs_to :company
	has_one :online_cancelation_policy
	
	accepts_nested_attributes_for :online_cancelation_policy

	#validates :email, :sms, :presence => true
	validate after_commit :extended_schedule

	def extended_schedule
		if self.extended_min_hour >= self.extended_max_hour
			errors.add(:base, "La hora de fin es menor o igual a la hora de inicio, para el horario extendido.")
		end
		location_ids = self.company.locations.pluck(:id)
		first_open_time = LocationTime.where(location_id: location_ids).order(:open).first.open
		last_close_time = LocationTime.where(location_id: location_ids).order(:close).last.close
		if self.extended_min_hour > first_open_time
			errors.add(:base, "La hora de inicio debe ser es menor o igual a la hora de apertura de todas las sucursales.")
		end
		if self.extended_max_hour < last_close_time
			errors.add(:base, "La hora de fin debe ser es mayor o igual a la hora de cierre de todas las sucursales.")
		end
	end

	def self.monthly_mails
		all.each do |setting|
			setting.update_attributes :monthly_mails => 0
		end
	end
end
