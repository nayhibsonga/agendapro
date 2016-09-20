class ReceiptType < ActiveRecord::Base
	has_many :receipts
end
