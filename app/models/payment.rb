class Payment < ActiveRecord::Base
  belongs_to :company
  belongs_to :receipt_type
  belongs_to :payment_method
  belongs_to :payment_method_type
  belongs_to :company_payment_method
  belongs_to :bank
  belongs_to :client
  belongs_to :location
  has_many :bookings, dependent: :nullify

  has_many :payment_products, dependent: :destroy
  has_many :products, through: :payment_products

  accepts_nested_attributes_for :payment_products, :reject_if => :all_blank, :allow_destroy => true
  accepts_nested_attributes_for :bookings, :reject_if => :all_blank, :allow_destroy => true
end
