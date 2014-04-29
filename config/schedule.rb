every 1.days, :at => '6 am' do
  runner "Booking.booking_reminder"
end

every 1.days, :at => '12 am' do
  runner "CompanySetting.daily_mails"
end

# every '0 2 20 * *' do
#   command "echo 'you can use raw cron sytax too'"
# end