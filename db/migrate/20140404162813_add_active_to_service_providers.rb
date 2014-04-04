class AddActiveToServiceProviders < ActiveRecord::Migration
  def change
    add_column :service_providers, :active, :boolean, :default => true
  end
end
