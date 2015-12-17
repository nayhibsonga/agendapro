class AddServiceToTreatmentPromo < ActiveRecord::Migration
  def change
  	add_column :treatment_promos, :service_id, :integer
  end
end
