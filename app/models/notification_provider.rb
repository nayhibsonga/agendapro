class NotificationProvider < ActiveRecord::Base
  belongs_to :service_provider
  belongs_to :notification_email
end
