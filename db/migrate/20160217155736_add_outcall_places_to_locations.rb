class AddOutcallPlacesToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :outcall_places, :text
  end
end
