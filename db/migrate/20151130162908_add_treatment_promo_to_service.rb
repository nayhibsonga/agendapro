class AddTreatmentPromoToService < ActiveRecord::Migration
  def change
  	add_column :services, :has_treatment_promo, :boolean, default: false
  	add_column :services, :treatment_promo_id, :integer
  end
end
