class AddScheduledResetOptionsToSalesCash < ActiveRecord::Migration
  def change
  	add_column :sales_cashes, :scheduled_reset, :boolean, default: false
  end
end
