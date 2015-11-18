class AddUserToInternalSale < ActiveRecord::Migration
  def change
  	add_column :internal_sales, :user_id, :integer
  end
end
