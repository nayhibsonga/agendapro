class NotificationProvider < ActiveRecord::Base
  belongs_to :provider
  belongs_to :notification_email
end
