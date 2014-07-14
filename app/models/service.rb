class Service < ActiveRecord::Base
	belongs_to :company
	belongs_to :service_category

	has_many :service_tags
	has_many :tags, :through => :service_tags

	has_many :service_resources
  	has_many :resources, :through => :service_resources

	has_many :bookings
	has_many :service_staffs
	has_many :service_providers, :through => :service_staffs

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than_or_equal_to: 5 }
	validates :price, numericality: { greater_than_or_equal_to: 0 }

	validate :group_service_capacity, :outcall_providers

	def group_service_capacity
		if self.group_service
			if !self.capacity || self.capacity < 1
				errors.add(:base, "Un servicio de grupo debe tener capacidad.")
			end
		end
	end

	def outcall_providers
		if !self.outcall
			outcall = false
			self.service_providers.each do |service_provider|
				if service_provider.active
					if service_provider.location.outcall
						outcall = true
					end
				end
			end
			if outcall
				errors.add(:base, "Un servicio no a domicilio no puede estar asociado a un local a domicilio.")
			end
		end
	end

	def name_with_small_outcall
		outcallString = ''
		if self.outcall
			outcallString = '<br /><small>(a domicilio)</small>'
		end
		self.name << outcallString
		self.name.html_safe
	end
end
