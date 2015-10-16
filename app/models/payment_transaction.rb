class PaymentTransaction < ActiveRecord::Base
	belongs_to :payment
	belongs_to :payment_method
	belongs_to :payment_method_type #Cedit card types
	belongs_to :company_payment_method
	belongs_to :bank

	validates :amount, presence: true
	validates :number, presence: true
end
