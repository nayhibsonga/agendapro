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
end
