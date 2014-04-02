# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


every 1.days, :at => '6 am' do
  runner "Booking.booking_reminder"
end

# every 1.month, :at => 'January 20th 2:00am' do
#   runner "Mailer.send_friend_sheet"
# end
# every '0 2 20 * *' do
#   command "echo 'you can use raw cron sytax too'"
# end