class CompanyFromEmail < ActiveRecord::Base
  belongs_to :company

  validates :email, :presence => true

  def confirmation_code
	crypt = ActiveSupport::MessageEncryptor.new(Agendapro::Application.config.secret_key_base)
	encrypted_data = crypt.encrypt_and_sign(self.id.to_s)
	return encrypted_data
  end
end
