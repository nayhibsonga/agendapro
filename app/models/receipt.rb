class Receipt < ActiveRecord::Base
	belongs_to :payment
	belongs_to :receipt_type
	has_many :receipt_products, dependent: :destroy
  	has_many :products, through: :receipt_products
  	has_many :bookings, dependent: :nullify

  	accepts_nested_attributes_for :receipt_products, :reject_if => :all_blank, :allow_destroy => true
  	accepts_nested_attributes_for :bookings, :reject_if => :all_blank

end
