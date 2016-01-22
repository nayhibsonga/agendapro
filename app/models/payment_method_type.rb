class PaymentMethodType < ActiveRecord::Base
	#These are credit card types
	
	has_many :payment_transactions
	has_many :payments, through: :payment_transactions
end
