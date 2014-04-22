class AddShowPriceToService < ActiveRecord::Migration
  def change
    add_column :services, :show_price, :boolean, :default => true
  end
end
