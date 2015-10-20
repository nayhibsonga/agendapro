set :output, "log/cron.log"

every 1.days, :at => '6 am' do
  runner "Client.bookings_reminder"
end

every '0 3 1 * *' do
  runner "CompanySetting.monthly_mails"
end

every 1.days, :at => '4 am' do
  runner "Company.payment_expiry"
  runner "Company.payment_shut"
  runner "Company.payment_inactive"
end

every 1.days, :at => '4:30 am' do
  runner "Company.add_due_amount"
end

every 1.days, :at => '5 am' do
  runner "Company.end_trial"
end

every '0 5 1 * *' do
  runner "Company.substract_month"
end

every 1.days, :at => '5:30 am' do
	runner "NotificationEmail.booking_summary"
end

every 1.days, :at => '3:00 am' do
	runner "StatsCompany.update_stats"
end

every 1.days, :at => '3 am' do
  runner "Company.invoice_email"
end

every 1.days, :at => '2:30 am' do
  runner 'Location.stock_reminders'
end
