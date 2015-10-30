class AddCloseOptionsToPettyCash < ActiveRecord::Migration
  def change
  	add_column :petty_cashes, :scheduled_close, :boolean, default: false
  	add_column :petty_cashes, :scheduled_keep_cash, :boolean, default: false
  	add_column :petty_cashes, :scheduled_cash, :float, default: 0.0
  end
end
