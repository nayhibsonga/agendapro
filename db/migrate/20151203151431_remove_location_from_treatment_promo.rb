class RemoveLocationFromTreatmentPromo < ActiveRecord::Migration
  def change
  	remove_column :treatment_promos, :location_id, :integer
  end
end
