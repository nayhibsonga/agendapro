set :output, "log/cron.log"

every 1.days, :at => '7 am' do
  runner "Client.bookings_reminder"
end

every '0 0 1 * *' do
  runner "CompanySetting.monthly_mails"
end

every 1.days, :at => '0 am' do
  runner "Company.payment_expiry"
  runner "Company.payment_shut"
  runner "Company.payment_inactive"
end

every 1.days, :at => '0:30 am' do
  runner "Company.add_due_amount"
end

every 1.days, :at => '1:30 am' do
  runner "Company.end_trial"
end

every '0 1 1 * *' do
  runner "Company.substract_month"
end

every 1.days, :at => '6:30 am' do
	runner "NotificationEmail.booking_summary"
end

every 1.days, :at => '6:00 am' do
	runner "StatsCompany.update_stats"
end

every 1.days, :at => '8 am' do
  runner "Company.invoice_email"
end
