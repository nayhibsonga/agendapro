class AddPromoCommissionToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :promo_commission, :float, default: 10.0
  	add_column :company_settings, :promo_offerer_capable, :boolean, default: false
  end
end
