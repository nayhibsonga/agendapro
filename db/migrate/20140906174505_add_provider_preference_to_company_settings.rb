class AddProviderPreferenceToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :provider_preference, :integer, defaul: 0
  end
end
