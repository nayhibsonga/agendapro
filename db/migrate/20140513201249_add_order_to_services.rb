class AddOrderToServices < ActiveRecord::Migration
  def change
    add_column :services, :order, :integer, :default => 0
  end
end
