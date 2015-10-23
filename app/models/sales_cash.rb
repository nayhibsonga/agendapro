class SalesCash < ActiveRecord::Base
	has_many :sales_cash_transactions
	belongs_to :location
	has_many :sales_cash_emails
	has_many :sales_cash_incomes
	has_many :sales_cash_logs
end
