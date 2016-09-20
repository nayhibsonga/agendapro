class SalesCashTransaction < ActiveRecord::Base
	belongs_to :sales_cash
	belongs_to :petty_transaction
	belongs_to :user
end
