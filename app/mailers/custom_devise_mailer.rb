class CustomDeviseMailer < Devise::Mailer
  layout "mailers/green_footer"

  before_action :default_options

  def reset_password_instructions(record, token, opts={})
    @resource = record
    @token = token

    # Defaults
    opts[:reply_to] = 'contacto@agendapro.cl'

    super
  end

  private
    def default_options
      @title = "AgendaPro"
      @url = "www.agendapro.co"
      attachments.inline['logo.png'] = File.read('app/assets/images/logos/logodoble2.png')
      headers["X-MC-PreserveRecipients"] = "false"
    end

end
