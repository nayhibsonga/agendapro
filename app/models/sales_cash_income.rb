class SalesCashIncome < ActiveRecord::Base
	belongs_to :sales_cash
	belongs_to :user
end
