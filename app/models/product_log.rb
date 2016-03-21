class ProductLog < ActiveRecord::Base
  belongs_to :product
  belongs_to :internal_sale
  belongs_to :payment_product
  belongs_to :service_provider
  belongs_to :client
  belongs_to :user
end
