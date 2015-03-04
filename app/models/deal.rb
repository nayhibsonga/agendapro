class Deal < ActiveRecord::Base
  belongs_to :company
  has_many :bookings, dependent: :nullify
end
