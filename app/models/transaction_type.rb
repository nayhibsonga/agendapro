class TransactionType < ActiveRecord::Base
	has_many :billing_logs, dependent: :destroy
	has_many :billing_records, dependent: :destroy
	validates :name, :description, :presence => true
end
