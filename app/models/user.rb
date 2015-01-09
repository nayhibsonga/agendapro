class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	belongs_to :role
	belongs_to :company

	has_many :bookings, dependent: :nullify
	has_many :booking_histories, dependent: :nullify

	has_many :user_locations, dependent: :destroy
	has_many :locations, :through => :user_locations

	has_many :user_providers, dependent: :destroy
	has_many :service_providers, :through => :user_providers

	accepts_nested_attributes_for :company

	validates :email, :role, :presence => true
	validate :location_company_users

	after_create :send_welcome_mail, :get_past_bookings

	def send_welcome_mail
		UserMailer.welcome_email(self)
	end

	def get_past_bookings
		Booking.where(client_id: Client.where(email: self.email)).each do |booking|
			booking.update(user_id: self.id)
		end
	end
	def location_company_users
		if Role.where(:name => ["Administrador Local","Recepcionista"]).include? self.role
			if self.locations.empty?
				errors.add(:base, "Este tipo de usuario debe tener al menos un local asociado.")
			end
		else
			if !self.locations.empty?
				errors.add(:base, "Este tipo de usuario no debe tener ningún local asociado.")
			end
		end
	end
	def provider_company_users
		if Role.where(:name => ["Staff"]).include? self.role
			if self.service_providers.empty?
				errors.add(:base, "Este tipo de usuario debe tener al menos un prestador asociado.")
			end
		else
			if !self.service_providers.empty?
				errors.add(:base, "Este tipo de usuario no debe tener ningún prestador asociado.")
			end
		end
	end
end
