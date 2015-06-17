class LocationProduct < ActiveRecord::Base
  belongs_to :product_id
  belongs_to :location_id
end
