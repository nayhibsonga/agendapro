class AddCompanieToServiceProvider < ActiveRecord::Migration
  def change
    add_column :service_providers, :company_id, :integer, :null => false
  end
end
