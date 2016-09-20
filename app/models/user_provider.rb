class UserProvider < ActiveRecord::Base
  belongs_to :user
  belongs_to :service_provider
end
