class PayUNotification < ActiveRecord::Base
  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  WORKER = 'ReceiptEmailWorker'
end
