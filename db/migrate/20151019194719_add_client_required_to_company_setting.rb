class AddClientRequiredToCompanySetting < ActiveRecord::Migration
  def change
  	add_column :company_settings, :payment_client_required, :boolean, default: true
  end
end
