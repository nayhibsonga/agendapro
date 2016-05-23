class SeedTotalTargetsFromEmailSendings < ActiveRecord::Migration
  Email::Sending.all.each do |sending|
    sending.update_columns(total_targets: sending.total_recipients)
  end
end
