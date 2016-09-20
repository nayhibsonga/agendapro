set :output, "log/cron.log"

every 1.days, :at => '7 am' do
  runner "Client.bookings_reminder"
end

every '0 0 1 * *' do
  runner "CompanySetting.monthly_mails"
  runner "Company.collect"
end

every '0 0 5 * *' do
  runner "Company.collect_reminder"
end

every '0 0 15 * *' do
  runner "Company.collect_insistence"
end

every '0 0 25 * *' do
  runner "Company.collect_ultimatum"
end

#For new blocking
every '0 0 10 * *' do
  runner "Company.collect_block"
end

#every 1.days, :at => '0 am' do
#  runner "Company.payment_expiry"
#  runner "Company.payment_shut"
#  runner "Company.payment_inactive"
#end

#every 1.days, :at => '0:30 am' do
#  runner "Company.add_due_amount"
#end

every 1.days, :at => '1:30 am' do
  runner "Company.end_trial"
  runner "Company.warn_trial"
  runner 'Company.former_trials_process'
end

#every '0 1 1 * *' do
#  runner "Company.substract_month"
#end

every 1.days, :at => '6:30 am' do
	runner "NotificationEmail.booking_summary"
end

every 1.days, :at => '4:00 am' do
	runner "StatsCompany.update_stats"
end

# every 1.days, :at => '8 am' do
#   runner "Company.invoice_email"
# end

every 1.days, :at => '2:30 am' do
  runner 'Location.stock_reminders'
end

every 1.days, :at => '0:30 am' do
  runner 'SalesCash.check_close'
end

every 1.days, :at => '0:15 am' do
  runner 'PettyCash.close_on_schedule'
end

every 1.day, :at => '5:15 am' do
  rake "-s sitemap:refresh"
end

# every 1.minutes do
#   runner 'SparkpostEmailLog.update_logs'
# end

environment = ENV['RAILS_ENV'] || 'production'
every :reboot do
    command "cd #{path} && #{environment_variable}=#{environment} bin/delayed_job -n4 restart"
end
