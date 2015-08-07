class AddLocationToPromo < ActiveRecord::Migration
  def change
  	add_column :promos, :location_id, :integer
  end
end
