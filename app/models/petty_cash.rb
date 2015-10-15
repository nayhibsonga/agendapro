class PettyCash < ActiveRecord::Base
	belongs_to :location
	has_many :petty_transactions

	def set_open(new_cash, transactioner_id, transactioner_type)
		if self.cash > new_cash
			petty_transaction = PettyTransaction.new
			petty_transaction.amount = self.cash - new_cash
			petty_transaction.is_income = false
			petty_transaction.transactioner_id = transactioner_id
			petty_transaction.transactioner_type = transactioner_type
			petty_transaction.notes = "Retiro en apertura de caja"
			petty_transaction.open = true
			petty_transaction.petty_cash_id = self.id
			petty_transaction.date = DateTime.now
			petty_transaction.save
		elsif self.cash < new_cash
			petty_transaction = PettyTransaction.new
			petty_transaction.amount = new_cash - self.cash
			petty_transaction.is_income = true
			petty_transaction.transactioner_id = transactioner_id
			petty_transaction.transactioner_type = transactioner_type
			petty_transaction.notes = "Ingreso en apertura de caja"
			petty_transaction.open = true
			petty_transaction.petty_cash_id = self.id
			petty_transaction.date = DateTime.now
			petty_transaction.save
		end
		self.open = true
		self.cash = new_cash
		self.save
	end

	def set_close(new_cash, transactioner_id, transactioner_type)
		if self.cash > new_cash
			petty_transaction = PettyTransaction.new
			petty_transaction.amount = self.cash - new_cash
			petty_transaction.is_income = false
			petty_transaction.transactioner_id = transactioner_id
			petty_transaction.transactioner_type = transactioner_type
			petty_transaction.notes = "Retiro en cierre de caja"
			petty_transaction.open = false
			petty_transaction.petty_cash_id = self.id
			petty_transaction.date = DateTime.now
			petty_transaction.save
		elsif self.cash < new_cash
			petty_transaction = PettyTransaction.new
			petty_transaction.amount = new_cash - self.cash
			petty_transaction.is_income = true
			petty_transaction.transactioner_id = transactioner_id
			petty_transaction.transactioner_type = transactioner_type
			petty_transaction.notes = "Ingreso en cierre de caja"
			petty_transaction.open = false
			petty_transaction.petty_cash_id = self.id
			petty_transaction.date = DateTime.now
			petty_transaction.save
		end
		self.open = false
		self.cash = new_cash
		self.save
		self.petty_transactions.where(open: true).each do |pt|
			pt.open = false
			pt.save
		end
	end

	def save_with_cash
		calc_amount = 0
		self.petty_transactions.where(open: true).each do |pt|
			if pt.is_income
				calc_amount = calc_amount + pt.amount
			else
				calc_amount = calc_amount - pt.amount
			end
		end
		if calc_amount >= 0
			self.cash = calc_amount
			self.save
			return true
		else
			return false
		end
	end

end
