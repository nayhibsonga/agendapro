class AddComissionToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :comission_value, :decimal, default: 0, null: false
    add_column :products, :comission_option, :integer, default: 0, null: false
  end
end
