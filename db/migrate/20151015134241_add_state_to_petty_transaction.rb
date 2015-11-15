class AddStateToPettyTransaction < ActiveRecord::Migration
  def change
  	add_column :petty_transactions, :open, :boolean, default: true
  end
end
