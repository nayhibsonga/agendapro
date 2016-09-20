class AddStatusToPettyCash < ActiveRecord::Migration
  def change
  	add_column :petty_cashes, :open, :boolean, default: false
  end
end
