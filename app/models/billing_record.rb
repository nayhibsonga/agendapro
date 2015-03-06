class BillingRecord < ActiveRecord::Base
	belongs_to :company
	belongs_to :transaction_type
end
