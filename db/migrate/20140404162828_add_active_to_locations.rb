class AddActiveToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :active, :boolean, :default => true
  end
end
