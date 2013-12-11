class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	belongs_to :role

	has_many :bookings
	has_one :staffs

	validates :first_name, :last_name, :email, :phone, :presence => true
end


