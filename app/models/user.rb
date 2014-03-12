class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	belongs_to :role
	belongs_to :company

	has_many :bookings
	has_many :service_providers

	accepts_nested_attributes_for :company

	validates :email, :presence => true
	validate :location_company_users

	after_create :send_welcome_mail, :get_past_bookings

	def send_welcome_mail
		UserMailer.welcome_email(self)
	end

	def get_past_bookings
		Booking.where(email: self.email).each do |booking|
			booking.update(user_id: self.id)
		end
	end
	def location_company_users
		if (self.role_id == Role.find_by_name("Administrador Local")) || (self.role_id == Role.find_by_name("Recepcionista"))
			if !self.location_id
				errors.add(:user, "Este tipo de usuario debe tener un local asociado.")
			end
		end
	end
end
