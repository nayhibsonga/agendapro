class AddUseIdentificationToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :use_identification_number, :boolean, default: false
  end
end
