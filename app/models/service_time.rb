class ServiceTime < ActiveRecord::Base
  belongs_to :service, :inverse_of => :service_times
  belongs_to :day

  validates :open, :close, :day, :presence => true
end
