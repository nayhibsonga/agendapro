class UserMailer < Base::CustomMailer
  layout :select_layout

  def welcome_email(user, recipient, password)
    # layout variables
    @title = "Bienvenido a AgendaPro"
    unless user.api_token.present?
      @header = "¡Bienvenido a HoraChic"
    else
      attacht_logo()
    end

    # view variables
    @user = user
    @password = password

    path = user.api_token.present? ? "horachic" : "agendapro"

    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: recipient,
      subject: @title,
      template_path: "mailers/#{path}"
      )
  end
  private
    def attacht_logo(url=nil)
      url ||= "app/assets/images/logos/logodoble2.png"
      attachments.inline['logo.png'] = File.read(url)
    end

    def select_layout
      if @user.api_token.present?
        "mailers/horachic"
      else
        "mailers/green"
      end
    end

end
