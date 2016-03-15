class TransformLocationDistrictsToOutcallPlaces < ActiveRecord::Migration
  def change
    Location.all.each do |location|
      outcall_places = ""
      District.where(id: LocationOutcallDistrict.where(location_id: location.id).pluck(:district_id)).each do |district|
        outcall_places << "#{district.name}\r\n"
      end
      location.update_column(:outcall_places, outcall_places.strip)
    end
  end
end
