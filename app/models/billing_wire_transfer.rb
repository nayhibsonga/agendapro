class BillingWireTransfer < ActiveRecord::Base
	belongs_to :company
	belongs_to :bank
end
