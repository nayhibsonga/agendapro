class PettyTransaction < ActiveRecord::Base

	belongs_to :petty_cash
	has_one :sales_cash_transaction

	def get_transactioner_details
	    if !self.transactioner_id.nil?
	      if self.transactioner_type == 0
	        return self.transactioner.public_name + " (prestador)"
	      elsif self.transactioner_type == 1
	        return self.transactioner.first_name + " " + self.transactioner.last_name + " (" + self.transactioner.role.name + ")"
	      else
	        return self.transactioner.name + " (cajero)"
	      end
	    else
	      return "Sin información"
	    end
	end

	def transactioner
	    
	    if self.transactioner_id.nil?
	      return nil
	    end

	    if self.transactioner_type == 0
	      return ServiceProvider.find(self.transactioner_id)
	    elsif self.transactioner_type == 1
	      return User.find(self.transactioner_id)
	    else
	      return Cashier.find(self.transactioner_id)
	    end

	end

	  #Has transactioner:
	  #    transactioner_id: 
	  # => id for service_provider or user
	  #    transactioner_type:
	  # => 0: service_provider
	  # => 1: user (staff, recepcionista, etc.)
	  # => 2: cashier 

end
