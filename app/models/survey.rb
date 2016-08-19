class Survey < ActiveRecord::Base
  belongs_to :client
  has_many :bookings

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  WORKER = 'SurveyEmailWorker'

  def confirmation_code
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
    return encrypted_data
  end
end
