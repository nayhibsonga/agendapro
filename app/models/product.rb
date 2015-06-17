class Product < ActiveRecord::Base
  belongs_to :company_id
  has_many :location_products
  has_many :locations, through: :location_products
  has_many :payment_products
  has_many :payments, through: :payment_products
end
