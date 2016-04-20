class PuntoPagosConfirmation < ActiveRecord::Base
	has_one :payed_booking

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  WORKER = 'ReceiptEmailWorker'
end
