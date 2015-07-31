class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :google_oauth2]
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
	validate :location_company_users, :provider_company_users

	after_create :send_welcome_mail, :get_past_bookings

	def send_welcome_mail
		UserMailer.welcome_email(self)
	end

	def get_past_bookings
		Booking.where(client_id: Client.where(email: self.email)).each do |booking|
			booking.update(user_id: self.id)
		end
		SessionBooking.where(client_id: Client.where(email: self.email)).each do |session_booking|
			session_booking.update(user_id: self.id)
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
		if Role.where(:name => ["Staff", "Staff (sin edición)"]).include? self.role
			if self.service_providers.empty?
				errors.add(:base, "Este tipo de usuario debe tener al menos un prestador asociado.")
			end
		else
			if !self.service_providers.empty?
				errors.add(:base, "Este tipo de usuario no debe tener ningún prestador asociado.")
			end
		end
	end

	def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    	user = User.where(:provider => auth.provider, :uid => auth.uid).first
	    if user
	      return user
	    else
	    	if auth.info.email.nil? || auth.info.email == ""

	    	else
		    	registered_user = User.where(:email => auth.info.email).first
		    	if registered_user
		        	return registered_user
		    	else
		    		user = User.create(:first_name => auth.info.first_name, :last_name => auth.info.last_name, :provider => auth.provider, :uid => auth.uid, :email => auth.info.email, :password => Devise.friendly_token[0,20], :role_id => Role.find_by_name("Usuario Registrado").id)
		      	end
	  		end
	  	end
	end

	def self.find_for_google_oauth2(auth, signed_in_resource=nil)

	    data = auth.info
	    user = User.where(:email => auth.info.email).first

	    # Uncomment the section below if you want users to be created if they don't exist
	    unless user
	        user = User.create(:first_name => auth.info.first_name,
	        	:last_name => auth.info.last_name,
	            :email => auth.info.email,
	            :password => Devise.friendly_token[0,20],
	            :provider => auth.provider,
	            :uid => auth.uid,
	            :role_id => Role.find_by_name("Usuario Registrado").id
	        )
	    end
	    user
	end


end
