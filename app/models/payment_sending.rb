class PaymentSending < ActiveRecord::Base
  belongs_to :payment

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  after_create :generate_sending

  WORKER = 'PaymentSendingEmailWorker'

  def generate_sending
    sendings.build(method: 'receipts').save
  end
end
