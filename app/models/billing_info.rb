class BillingInfo < ActiveRecord::Base
  belongs_to :company

  validates :name, :rut, :address, :sector, :company_id, presence: true
end
