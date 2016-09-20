class SurveyConstructMailer < Base::CustomMailer
	layout "mailers/green"
	def survey(book, recipient, options = {})
		@title = "Encuenta de Satisfacción"
    @company = book.location.company
    @book = book
    mail(
      from: sender_from_company(@company),
      reply_to: filter_sender(@book.location.email),
      to: recipient,
      subject: @title,
      template_path: "mailers/survey"
      )
	end
end
