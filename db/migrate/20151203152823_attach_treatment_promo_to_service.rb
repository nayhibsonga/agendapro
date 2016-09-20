class AttachTreatmentPromoToService < ActiveRecord::Migration
  def change
  	add_column :bookings, :treatment_promo_id, :integer
  	add_column :services, :active_treatment_promo_id, :integer
  	add_column :services, :active_last_minute_promo_id, :integer
  	remove_column :last_minute_promos, :location_id, :integer
  end
end
