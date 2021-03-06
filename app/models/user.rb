class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:facebook, :facebook_marketplace, :google_oauth2, :google_oauth2_marketplace]
	belongs_to :role
	belongs_to :company

	has_many :user_searches

	has_many :bookings, dependent: :nullify
	has_many :booking_histories, dependent: :nullify

	has_many :user_locations, dependent: :destroy
	has_many :locations, :through => :user_locations

	has_many :user_providers, dependent: :destroy
	has_many :service_providers, :through => :user_providers

	has_many :favorites, dependent: :destroy
	has_many :favorite_locations, through: :favorites, source: :location

	has_many :internal_sales, dependent: :nullify
	has_many :product_logs, dependent: :nullify
	has_many :sendings, class_name: 'Email::Sending', as: :sendable
	has_many :treatment_logs, dependent: :nullify
	has_many :super_admin_logs, dependent: :nullify

	accepts_nested_attributes_for :company

	validates :email, :role, :presence => true
	validate :location_company_users, :provider_company_users

	after_create :send_welcome_mail, :get_past_bookings

	WORKER = 'UserEmailWorker'

	def send_welcome_mail
		unless Role.where(name: ["Staff", "Recepcionista", "Admnistrador Local", "Staff (sin edición)"]).include? self.role
			sendings.build(method: 'welcome_email').save
		end
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

	def request_mobile_token
		while self.mobile_token.blank? || User.where(mobile_token: self.mobile_token).where.not(id: self.id).count > 0
			self.mobile_token = SecureRandom.base64(32)
		end
	end

	def request_api_token
		while self.api_token.blank? || User.where(api_token: self.api_token).where.not(id: self.id).count > 0
			self.api_token = SecureRandom.base64(32)
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

	def full_name
		"#{self.first_name} #{self.last_name}"
	end

	#Check if Staff or Recepcionista have no providers or locations associated (or are inactive)
	def is_disabled
		if self.role_id == Role.find_by_name("Recepcionista").id
			if self.locations.where(active: true).count == 0
				return true
			end
		elsif self.role_id == Role.find_by_name("Staff").id || self.role_id == Role.find_by_name("Staff (sin edición)").id
			if self.service_providers.where(active: true).count == 0
				return true
			end
		end
		return false
	end

end
