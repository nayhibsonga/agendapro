class AddBlockLengthToServiceProviders < ActiveRecord::Migration
  def change
    add_column :service_providers, :block_length, :integer, :default => 30
  end
end
