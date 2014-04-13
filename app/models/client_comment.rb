class ClientComment < ActiveRecord::Base
  belongs_to :client_profile
end
