class InternalSale < ActiveRecord::Base
	belongs_to :location
	belongs_to :cashier
	belongs_to :service_provider
	belongs_to :product
	belongs_to :user
end
