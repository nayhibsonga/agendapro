class CompanyFromEmailMailer < Base::CustomMailer
  layout "mailers/green"

	def confirm_email (email_from, recipient)
    @company = email_from.company

    # layout variables
    @title = "Confirmar email #{@email_from.email}"
    @url = @company.web_url
    attacht_logo()

    # view variables
    @email_from = email_from

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
