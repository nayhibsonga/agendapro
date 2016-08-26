class SurveyEmailWorker < BaseEmailWorker

  def self.perform(sending)
    @title = "Encuenta de Satisfacción"
    method = sending.method
    booking = Survey.find(sending.sendable_id).bookings.last
    recipients = booking.client.email
    company_settings = (booking.client.company.company_setting.after_survey)*60
    timezone = CustomTimezone.from_company(booking.client.company)
    send_survey(booking, company_settings, timezone, method, recipients)
  end
  def self.send_survey(booking, company_settings, timezone, method, recipients)
    time = (booking.end + company_settings.to_i) - timezone.offset
    SurveyMailer.delay(run_at: time).send(method, booking, recipients, nil)
  end
end
