class ServiceCategory < ActiveRecord::Base
  belongs_to :company

  has_many :services
end
