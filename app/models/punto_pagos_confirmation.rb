class PuntoPagosConfirmation < ActiveRecord::Base
	has_one :payed_booking
end
