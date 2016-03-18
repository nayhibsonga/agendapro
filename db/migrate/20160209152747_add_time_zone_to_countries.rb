class AddTimeZoneToCountries < ActiveRecord::Migration
  def change
    add_column :countries, :timezone_name, :string
    add_column :countries, :timezone_offset, :float
  end
end
