class TransformLocationDistrictToCountry < ActiveRecord::Migration
  def change
    Location.all.each do |location|
      country = location.district.city.region.country
      location.update(country: country)
    end
  end
end
