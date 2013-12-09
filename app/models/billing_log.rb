class BillingLog < ActiveRecord::Base
	belongs_to :transaction_type
	belongs_to :plan
	belongs_to :company

	validates :date, :payment, :amount, :next_payment, :presence => true
end
