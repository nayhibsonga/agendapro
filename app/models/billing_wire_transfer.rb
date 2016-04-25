class BillingWireTransfer < ActiveRecord::Base
	belongs_to :company
	belongs_to :bank

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  WORKER = 'BillingWireTransferEmailWorker'
end
