class AddDefaultPriceToServices < ActiveRecord::Migration
  def change
  	change_column :services, :price, :float, :default => 0.0
  end
end
