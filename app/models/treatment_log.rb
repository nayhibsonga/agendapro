class TreatmentLog < ActiveRecord::Base
  belongs_to :client
  belongs_to :user
  belongs_to :service
end
