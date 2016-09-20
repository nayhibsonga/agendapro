class ChangeInternalSaleDate < ActiveRecord::Migration
  def change
  	remove_column :internal_sales, :date, :date
  	add_column :internal_sales, :date, :datetime, default: DateTime.now
  end
end
