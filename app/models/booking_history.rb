class BookingHistory < ActiveRecord::Base
  belongs_to :booking
  #belongs_to :staff_code
  belongs_to :employee_code
  belongs_to :status
  belongs_to :service
  belongs_to :service_provider
  belongs_to :user
end
