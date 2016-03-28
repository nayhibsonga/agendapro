class UserMailer < Base::CustomMailer

  def welcome_email(user, recipient)
    layout "mailers/#{user.api_token.present? ? "horachic" : "green"}"

    # layout variables
    @title = "Bienvenido a AgendaPro"
    unless user.api_token.present?
      @header = "¡Bienvenido a HoraChic"
    else
      attacht_logo()
    end

    # view variables
    @user = user

    path = user.api_token.present? ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: filter_recipient(recipient),
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end

  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

end
