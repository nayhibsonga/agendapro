class ClientComment < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  belongs_to :last_modifier, class_name: "User"
end
