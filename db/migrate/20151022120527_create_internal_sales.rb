class CreateInternalSales < ActiveRecord::Migration
  def change
    create_table :internal_sales do |t|
      t.integer :location_id
      t.integer :cashier_id
      t.integer :service_provider_id
      t.integer :product_id
      t.integer :quantity, default: 1
      t.float :list_price, default: 0.0
      t.float :price, default: 0.0
      t.float :discount, default: 0.0
      t.date :date, default: DateTime.now.to_date

      t.timestamps
    end
  end
end
