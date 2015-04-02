class AddDealRequiredToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :deal_required, :boolean, default: false, null: false
  end
end
