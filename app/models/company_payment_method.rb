class CompanyPaymentMethod < ActiveRecord::Base
  belongs_to :company
  has_many :payments
end
