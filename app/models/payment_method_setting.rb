class PaymentMethodSetting < ActiveRecord::Base
  belongs_to :company_setting
  belongs_to :payment_method
end
