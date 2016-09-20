class Receipt < ActiveRecord::Base
	belongs_to :payment
	belongs_to :receipt_type
	has_many :payment_products, dependent: :nullify
  	has_many :products, through: :payment_products
  	has_many :bookings, dependent: :nullify
  	has_many :mock_bookings, dependent: :nullify

  	accepts_nested_attributes_for :payment_products, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :bookings, :reject_if => :all_blank

end
