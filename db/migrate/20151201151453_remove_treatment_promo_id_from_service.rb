class RemoveTreatmentPromoIdFromService < ActiveRecord::Migration
  def change
  	remove_column :services, :treatment_promo_id, :integer
  end
end
