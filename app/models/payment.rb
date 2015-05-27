class Payment < ActiveRecord::Base
  belongs_to :company
  belongs_to :receipt_type
  belongs_to :payment_method
  belongs_to :payment_method_type
  belongs_to :bank
end
