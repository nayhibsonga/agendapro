class ChangeAddressToJson < ActiveRecord::Migration
  def change
    locations_address = []
    Location.all.each do |local|
      location = {
        id: local.id,
        address: [
          generateHash("", ["street_number"]),
          generateHash(local.address, ["route"]),
          generateHash(local.district.name, ["locality", "political"]),
          generateHash(local.district.name, ["administrative_area_level_3", "political"]),
          generateHash(local.district.city.name, ["administrative_area_level_2", "political"]),
          generateHash(local.district.city.region.name, ["administrative_area_level_1", "political"]),
          generateHash(local.district.city.region.country.name, ["country", "political"])
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
