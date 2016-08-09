class SurveyMailer < Base::CustomMailer
	layout "mailers/green"
	def survey(client,booking)
		@title = "Encuenta de Satisfacción"
		@booking = booking.name
    mail(
      from: filter_sender(),
      reply_to: filter_sender(),
      to: client.email,
      subject: @title,
      template_path: "mailers/survey"
      )
	end
end
