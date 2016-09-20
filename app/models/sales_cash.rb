class SalesCash < ActiveRecord::Base
	has_many :sales_cash_transactions
	belongs_to :location
	has_many :sales_cash_emails
	has_many :sales_cash_incomes
	has_many :sales_cash_logs

	def self.check_close

		now = DateTime.now

		SalesCash.all.each do |sales_cash|
			if sales_cash.scheduled_reset
				if sales_cash.scheduled_reset_monthly
					if sales_cash.scheduled_reset_day >= now.mday

						sales_cash.sales_cash_incomes.where('date <= ?', now).each do |income|
					      income.open = false
					      income.save
					    end

					    sales_cash.sales_cash_transactions.where('date <= ?', now).each do |transaction|
					      transaction.open = false
					      transaction.save
					    end

					    old_cash = sales_cash.cash
					    old_reset_date = sales_cash.last_reset_date

					    sales_cash.last_reset_date = now
					    sales_cash.cash = 0.0

					    SalesCashLog.create(sales_cash_id: sales_cash.id, start_date: old_reset_date, end_date: now, remaining_amount: old_cash)

					    sales_cash.save

					end
				else
					if now.cwday == sales_cash.scheduled_reset_day
						sales_cash.sales_cash_incomes.where('date <= ?', now).each do |income|
					      income.open = false
					      income.save
					    end

					    sales_cash.sales_cash_transactions.where('date <= ?', now).each do |transaction|
					      transaction.open = false
					      transaction.save
					    end

					    old_cash = sales_cash.cash
					    old_reset_date = sales_cash.last_reset_date

					    sales_cash.last_reset_date = now
					    sales_cash.cash = 0.0

					    SalesCashLog.create(sales_cash_id: sales_cash.id, start_date: old_reset_date, end_date: now, remaining_amount: old_cash)
					    
					    sales_cash.save
					end
				end
			end
		end

	end

end
