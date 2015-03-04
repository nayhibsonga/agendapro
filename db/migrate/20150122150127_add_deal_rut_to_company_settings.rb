class AddDealRutToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :deal_identification_number, :boolean, default: false
  end
end
