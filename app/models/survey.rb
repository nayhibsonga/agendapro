class Survey < ActiveRecord::Base
  belongs_to :client
  has_one :booking
end
