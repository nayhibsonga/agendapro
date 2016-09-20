class AddComissionToService < ActiveRecord::Migration
  def change
    add_column :services, :comission_value, :decimal, default: 0, null: false
    add_column :services, :comission_option, :integer, default: 0, null: false
  end
end
