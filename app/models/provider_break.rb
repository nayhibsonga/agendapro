class ProviderBreak < ActiveRecord::Base
  belongs_to :service_provider

  validates :start, :end, :presence => true

  validate :time_empty_or_negative

	def time_empty_or_negative
		if self.start >= self.end
			errors.add(:base, "Existen horarios vacíos o negativos.")
		end
	end
end
