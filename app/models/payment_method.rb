class PaymentMethod < ActiveRecord::Base
	has_many :payment_method_settings
	has_many :company_settings, through: :payment_method_settings
end
