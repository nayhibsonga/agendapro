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

	after_create :send_welcome_mail, :get_past_bookings

	def send_welcome_mail
		UserMailer.welcome_email(self)
	end

	def get_past_bookings
		Booking.where(email: self.email).each do |booking|
			booking.user_id = self.id
			booking.save
		end
	end
end
