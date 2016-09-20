class ChangeBlockLengthDefaultsToServiceProviders < ActiveRecord::Migration
  def change
  	change_column :service_providers, :block_length, :integer, default: 15
  end
end
