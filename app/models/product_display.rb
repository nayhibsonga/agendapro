class ProductDisplay < ActiveRecord::Base
	belongs_to :company
	has_many :products
end
