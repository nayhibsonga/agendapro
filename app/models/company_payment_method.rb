class CompanyPaymentMethod < ActiveRecord::Base
  belongs_to :company
  has_many :payment_transactions
  has_many :payments, through: :payment_transactions
end
