class UserEmailWorker

  def self.perform(user_id)
    user = User.find(user_id)
    if user.api_token.present?
      UserMailer.delay.welcome_email_legacy(user)
    else
      UserMailer.delay.welcome_email(user)
    end
  end

end
