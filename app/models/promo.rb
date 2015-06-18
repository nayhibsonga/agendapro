class Promo < ActiveRecord::Base
	belongs_to :service
	belongs_to :day
end
