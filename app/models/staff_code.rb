class StaffCode < ActiveRecord::Base
  belongs_to :company

  validates :staff, :code, :company, :presence => true
  validates :code, uniqueness: { scope: :company }
end
