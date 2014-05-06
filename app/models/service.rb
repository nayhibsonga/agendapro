class Service < ActiveRecord::Base
	belongs_to :company
	belongs_to :service_category

	has_many :service_tags
	has_many :tags, :through => :service_tags

	has_many :bookings
	has_many :service_staffs
	has_many :service_providers, :through => :service_staffs

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than: 5 }
	validates :price, numericality: { greater_than: -1 }

	validate :group_service_capacity

	def group_service_capacity
		if self.group_service
			if !self.capacity || self.capacity < 1
				errors.add(:base, "Un servicio de grupo debe tener capacidad.")
			end
		end
	end
end
