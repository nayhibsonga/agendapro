class Cashier < ActiveRecord::Base
	belongs_to :company
	has_many :payments

	validate :code_uniqueness

	def code_uniqueness
		if self.code.nil? || self.code == ""
			errors.add(:base, "El código de cajero no puede estar vacío.")
			return
		end
		Cashier.where(:company_id => self.company_id, :code => self.code).each do |cashier|
			if cashier != self && cashier.code != "" && cashier.code == self.code
				errors.add(:base, "No puede haber dos cajeros con el mismo código.")
			end
		end
	end

end
