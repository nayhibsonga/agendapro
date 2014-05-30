class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	belongs_to :role
	belongs_to :company
	belongs_to :location

	has_many :bookings
	has_many :service_providers

	accepts_nested_attributes_for :company

	validates :email, :role, :presence => true
	validate :location_company_users

	after_create :send_welcome_mail, :get_past_bookings

	def send_welcome_mail
		UserMailer.welcome_email(self)
	end

	def get_past_bookings
		Booking.where(client_id: Client.where(self.email)).each do |booking|
			booking.update(user_id: self.id)
		end
	end
	def location_company_users
		if Role.where(:name => ["Administrador Local","Recepcionista","Staff"]).include? self.role
			if !self.location
				errors.add(:base, "Este tipo de usuario debe tener un local asociado.")
			end
		else
			if self.location
				errors.add(:base, "Este tipo de usuario no debe tener un local asociado.")
			end
		end
	end
end
