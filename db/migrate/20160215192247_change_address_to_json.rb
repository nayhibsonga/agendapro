class ChangeAddressToJson < ActiveRecord::Migration
  def change
    locations_address = []
    Location.all.each do |local|
      district = local.district_id && District.find(local.district_id) ? District.find(local.district_id).name : ""
      city = district.present? && City.find(District.find(local.district_id).city_id) ? City.find(District.find(local.district_id).city_id).name : ""
      region = city.present? && Region.find(City.find(District.find(local.district_id).city_id).region_id) ? Region.find(City.find(District.find(local.district_id).city_id).region_id).name : ""
      country = region.present? && Country.find(Region.find(City.find(District.find(local.district_id).city_id).region_id).country_id) ? Country.find(Region.find(City.find(District.find(local.district_id).city_id).region_id).country_id).name : ""
      location = {
        id: local.id,
        address: [
          generateHash("", ["street_number"]),
          generateHash(local.address, ["route"]),
          generateHash(district, ["locality", "political"]),
          generateHash(district, ["administrative_area_level_3", "political"]),
          generateHash(city, ["administrative_area_level_2", "political"]),
          generateHash(region, ["administrative_area_level_1", "political"]),
          generateHash(country, ["country", "political"])
        ]
      }
      locations_address.push(location)

      local.update_column(:address, "{\"dir\":\"#{local.address}\"}")
    end

    change_column :locations, :address, "JSON USING CAST(address AS JSON)"

    locations_address.each do |location|
      local = Location.find(location[:id])
      local.update_column(:address, location[:address].to_json)
    end
  end

  def generateHash(value, types)
    address = {
      long_name: value,
      short_name: value,
      types: types
    }
  end
end
