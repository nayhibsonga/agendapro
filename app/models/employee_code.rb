class EmployeeCode < ActiveRecord::Base
  belongs_to :company
  has_many :payments, dependent: :nullify
  has_many :internal_sales, dependent: :nullify
  has_many :booking_histories, dependent: :nullify
end
