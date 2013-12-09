class TransactionType < ActiveRecord::Base
	has_many :billing_logs

	validates :name, :description, :presence => true
end
