class Service < ActiveRecord::Base
	require 'pg_search'
	include PgSearch

	belongs_to :company
	belongs_to :service_category

	has_many :service_tags, dependent: :destroy
	has_many :tags, :through => :service_tags

	has_many :service_resources, dependent: :destroy
  	has_many :resources, :through => :service_resources

	has_many :bookings, dependent: :destroy
	has_many :service_staffs, dependent: :destroy
	has_many :service_providers, :through => :service_staffs

	has_many :service_promos
	has_many :last_minute_promos

	mount_uploader :time_promo_photo, TimePromoPhotoUploader

	scope :with_time_promotions, -> { where(has_time_discount: true, active: true, online_payable: true, online_booking: true, time_promo_active: true) }
	scope :with_last_minute_promotions, -> { where(has_last_minute_discount: true, active: true, online_payable: true, online_booking: true)}

	accepts_nested_attributes_for :service_category, :reject_if => :all_blank, :allow_destroy => true

	validates :name, :duration, :company, :service_category, :presence => true
	validates :duration, numericality: { greater_than_or_equal_to: 5, :less_than_or_equal_to => 1439 }
	validates :price, numericality: { greater_than_or_equal_to: 0 }

	validate :group_service_capacity, :outcall_providers

	pg_search_scope :search, 
	:against => :name,
	:associated_against => {
		:service_category => :name
	},
	:using => {
                :trigram => {
                  	:threshold => 0.1,
                  	:prefix => true,
                	:any_word => true
                },
                :tsearch => {
                	:prefix => true,
                	:any_word => true
                }
    },
    :ignoring => :accents

    #def active_service_promo
    #	if self.active_service_promo_id.nil?
    #		return nil
    #	else
    #		return ServicePromo.find(self.active_service_promo_id)
    #	end
    #end

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

	def get_max_time_discount

		discount = 0

		if self.has_time_discount && !self.active_service_promo_id.nil?
			
			service_promo = ServicePromo.find(self.active_service_promo_id)
			service_promo.promos.each do |promo|
				if promo.morning_discount > discount
					discount = promo.morning_discount
				end
				if promo.afternoon_discount > discount
					discount = promo.afternoon_discount
				end
				if promo.night_discount > discount
					discount = promo.night_discount
				end
			end

		end

		return discount

	end

	def active_promo_max
		if self.active_service_promo_id.nil?
			return 0
		else
			service_promo = ServicePromo.find(self.active_service_promo_id)
			service_promo.max_bookings
		end
	end

	def active_promo_left_bookings

		if self.active_service_promo_id.nil?

			return 0

		else

			service_promo = ServicePromo.find(self.active_service_promo_id)
			bookings_count = Booking.where(:service_promo_id => service_promo.id, :is_session => false).where('status_id <> ?', Status.find_by_name('Cancelado')).count
			session_bookings_count = SessionBooking.where(:service_promo_id => service_promo.id).count

			return service_promo.max_bookings - (bookings_count + session_bookings_count)

		end

	end

	def get_last_minute_hours(location_id)
		if !self.has_last_minute_discount
			return 0
		else
			promo = LastMinutePromo.where(:service_id => self.id, :location_id => location_id).first
			return promo.hours
		end
	end

	def get_last_minute_discount(location_id)
		if !self.has_last_minute_discount
			return 0
		else
			promo = LastMinutePromo.where(:service_id => self.id, :location_id => location_id).first
			return promo.discount
		end
	end

	def get_last_minute_available_hours(provider_id)

		if provider_id.nil? || provider_id == "0"
			self.service_providers.each do |service_provider|

			end
		else
			service_provider = ServiceProvider.find(provider_id)
		end

	end

end
