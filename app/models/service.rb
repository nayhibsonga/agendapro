class Service < ActiveRecord::Base
	belongs_to :company
	belongs_to :service_category

	has_many :service_tags, dependent: :destroy
	has_many :tags, :through => :service_tags

	has_many :service_resources, dependent: :destroy
  	has_many :resources, :through => :service_resources

	has_many :bookings, dependent: :destroy
	has_many :service_staffs, dependent: :destroy
	has_many :service_providers, :through => :service_staffs

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than_or_equal_to: 5 }
	validates :price, numericality: { greater_than_or_equal_to: 0 }

	validate :group_service_capacity, :outcall_providers

	def self.week_bookings(offset, company_id)

		Booking.where(service_id: where(active: true, company_id: company_id).pluck(:id), start: (1+offset).weeks.ago..offset.weeks.ago).count
	end

	def self.month_bookings(offset, company_id)
		Booking.where(service_id: where(active: true, company_id: company_id).pluck(:id), start: (1+offset).months.ago..offset.months.ago).count
	end

	def week_bookings(offset)
		Booking.where(service: self, start: (1+offset).weeks.ago..offset.weeks.ago).count
	end

	def month_bookings(offset)
		Booking.where(service: self, start: (1+offset).months.ago..offset.months.ago).count
	end

	def week_sp_bookings(offset, service_provider)
		Booking.where(service_provider: service_provider, service: self, start: (1+offset).weeks.ago..offset.weeks.ago).count
	end

	def month_sp_bookings(offset, service_provider)
		Booking.where(service_provider: service_provider, service: self, start: (1+offset).months.ago..offset.months.ago).count
	end

	def week_location_bookings(offset, location)
		Booking.where(location: location, service: self, start: (1+offset).weeks.ago..offset.weeks.ago).count
	end

	def month_location_bookings(offset, location)
		Booking.where(location: location, service: self, start: (1+offset).months.ago..offset.months.ago).count
	end

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
