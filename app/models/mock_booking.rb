class MockBooking < ActiveRecord::Base
	belongs_to :service
	belongs_to :service_provider
	belongs_to :client
	belongs_to :payment
	belongs_to :receipt
end
