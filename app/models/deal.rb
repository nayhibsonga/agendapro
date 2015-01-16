class Deal < ActiveRecord::Base
  belongs_to :company_id
  has_many :bookings
end
