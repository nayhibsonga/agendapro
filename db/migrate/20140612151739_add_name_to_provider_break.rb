class AddNameToProviderBreak < ActiveRecord::Migration
  def change
    add_column :provider_breaks, :name, :string
  end
end
