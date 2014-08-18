class AddClientExclusiveToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :client_exclusive, :boolean, default: false
  end
end
