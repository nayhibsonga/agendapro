class MockBooking < ActiveRecord::Base
	belongs_to :service
	belongs_to :service_provider
	belongs_to :client
	belongs_to :payment
	belongs_to :receipt

	def get_commission

		if self.service_provider_id.nil? || self.service.nil?
			return 0
		else
			service_commission = ServiceCommission.where(:service_id => self.service_id, :service_provider_id => self.service_provider_id).first
		    if !service_commission.nil? && !service_commission.amount.nil?
		      if service_commission.is_percent
		        return self.price * service_commission.amount / 100
		      else
		        return service_commission.amount
		      end
		    else
		      if self.service.comission_option == 0
		        return self.price * self.service.comission_value / 100
		      else
		        return self.service.comission_value
		      end
		    end
		end

	end

end
