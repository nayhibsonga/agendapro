class UserMailer < Base::CustomMailer
  layout "mailers/green"

  def welcome_email(user, recipient)
    # layout variables
    @title = "Bienvenido a AgendaPro"
    unless user.api_token.present?
      @header = "¡Bienvenido a HoraChic"
    else
      attacht_logo()
    end

    # view variables
    @user = user

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/agendapro"
      )
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

end
