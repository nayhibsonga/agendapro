class SurveyEmailWorker < BaseEmailWorker

  def self.perform(sending)
    @title = "Encuenta de Satisfacción"
    method = sending.method
    booking = Survey.find(sending.sendable_id).bookings.first
    recipients = booking.client.email
    SurveyMailer.delay.send(method, booking, recipients, nil)
  end

end
