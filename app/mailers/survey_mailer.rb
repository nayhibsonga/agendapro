class SurveyMailer < Base::CustomMailer
	layout "mailers/green"
	def survey(booking)
		@title = "Encuenta de Satisfacción"
		@booking = booking.service.name
    @client = booking.client
    @book = booking.confirmation_code
    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: @client.email,
      subject: @title,
      template_path: "mailers/survey"
      )
	end
end
