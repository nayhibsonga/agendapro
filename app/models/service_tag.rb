class ServiceTag < ActiveRecord::Base
  belongs_to :service
  belongs_to :tag
end
