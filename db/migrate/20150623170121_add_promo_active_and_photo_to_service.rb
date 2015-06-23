class AddPromoActiveAndPhotoToService < ActiveRecord::Migration
  def change
  	add_column :services, :time_promo_active, :boolean, default: false
  	add_column :services, :time_promo_photo, :string, default: ""
  end
end
