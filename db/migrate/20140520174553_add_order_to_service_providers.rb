class AddOrderToServiceProviders < ActiveRecord::Migration
  def change
    add_column :service_providers, :order, :integer, :default => 0
  end
end
