class PaymentStatus < ActiveRecord::Base
	has_many :companies, dependent: :restrict_with_error

	validates :name, :description, :presence => true
end
