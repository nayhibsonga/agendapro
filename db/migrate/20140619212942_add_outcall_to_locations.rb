class AddOutcallToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :outcall, :boolean, default: false
  end
end
