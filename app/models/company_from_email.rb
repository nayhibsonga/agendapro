class CompanyFromEmail < ActiveRecord::Base
  belongs_to :company

  has_many :sendings, class_name: 'Email::Sending', as: :sendable

  validates :email, :presence => true

  after_create :confirm_email

  WORKER = 'CompanyFromEmailWorker'

  def confirm_email
    sendings.build(method: 'confirm_email').save
  end

  def confirmation_code
    crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
    encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
    return encrypted_data
  end
end
