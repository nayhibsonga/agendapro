class AddDefaultLocationToCountry < ActiveRecord::Migration
  def change
    add_column :countries, :latitude, :float
    add_column :countries, :longitude, :float
    add_column :countries, :formatted_address, :string, default: ""
  end
end
