class NotificationLocation < ActiveRecord::Base
  belongs_to :location
  belongs_to :notification_email
end
