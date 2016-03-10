class TransformLocationDistrictToCountry < ActiveRecord::Migration
  def change
    Location.all.each do |location|
      district = location.district_id && District.find(location.district_id) ? District.find(location.district_id) : nil
      city = district.present? && City.find(District.find(location.district_id).city_id) ? City.find(District.find(location.district_id).city_id) : nil
      region = city.present? && Region.find(City.find(District.find(location.district_id).city_id).region_id) ? Region.find(City.find(District.find(location.district_id).city_id).region_id) : nil
      country = region.present? && Country.find(Region.find(City.find(District.find(location.district_id).city_id).region_id).country_id) ? Country.find(Region.find(City.find(District.find(location.district_id).city_id).region_id).country_id) : nil
      location.update(country_id: country.id)
    end
  end
end
