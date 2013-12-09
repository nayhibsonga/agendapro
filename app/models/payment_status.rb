class PaymentStatus < ActiveRecord::Base
	has_many :companies

	validates :name, :description, :presence => true
end
