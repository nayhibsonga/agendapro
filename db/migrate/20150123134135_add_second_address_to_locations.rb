class AddSecondAddressToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :second_address, :string
  end
end
