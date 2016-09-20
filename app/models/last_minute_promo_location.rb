class LastMinutePromoLocation < ActiveRecord::Base
	belongs_to :last_minute_promo
	belongs_to :location
end
