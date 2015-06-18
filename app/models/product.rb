class Product < ActiveRecord::Base
  belongs_to :company
  has_many :location_products
  has_many :locations, through: :location_products
  has_many :payment_products
  has_many :payments, through: :payment_products

  accepts_nested_attributes_for :location_products, :reject_if => :all_blank, :allow_destroy => true
end
