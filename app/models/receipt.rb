class Receipt < ActiveRecord::Base
	belongs_to :payment
	belongs_to :receipt_type
	has_many :receipt_products, dependent: :destroy
  	has_many :products, through: :receipt_products
  	has_many :bookings
end
