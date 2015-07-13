class CreateLocationProducts < ActiveRecord::Migration
  def change
    create_table :location_products do |t|
      t.references :product_id, index: true, null: false
      t.references :location_id, index: true, null: false
      t.integer :stock, default: 0

      t.timestamps
    end
  end
end
