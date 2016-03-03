class CompanyFromEmailMailer < Base::CustomMailer

	def confirm_email (email, company)
    @email = email
    @company = company
    @url = @company.web_url

    subject = "Confirmar email #{@email.email}"
    recipient = "#{@email.email}"

    mail(
      from: filter_sender("AgendaPro <no-reply@agendapro.cl>"),
      to: filter_recipient(recipient),
      subject: subject,
      template_path: "mailers"
      )
	end
end
