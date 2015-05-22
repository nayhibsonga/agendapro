set :output, "log/cron.log"

every 1.days, :at => '6 am' do
  runner "Booking.booking_reminder"
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

every 1.days, :at => '2:35 pm' do
  puts "al log"
end

every 1.days, :at => '5 am' do
  runner "Company.end_trial"
end

every '0 5 1 * *' do
  runner "Company.substract_month"
end

every 1.days, :at => '5:30 am' do
	runner "Location.booking_summary"
	runner "ServiceProvider.booking_summary"
end
