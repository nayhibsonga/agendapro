class AddShowSalesCashToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :show_cashes, :boolean, default: false
  end
end
