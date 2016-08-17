class SurveyConstructEmailWorker < BaseEmailWorker

  def self.perform(sending)
    @title = "Encuenta de Satisfacción"
    #@booking = booking.service.name
    #@client = booking.client
    #@book = booking.confirmation_code
    method = sending.method
    booking = Booking.find(sending.sendable_id)
    #recipients = booking.client.email
    #SurveyConstructMailer.delay.send(method, booking, recipients, nil)
  end

end
