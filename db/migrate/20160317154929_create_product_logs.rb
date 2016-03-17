class CreateProductLogs < ActiveRecord::Migration
  def change
    create_table :product_logs do |t|
      t.integer :product_id
      t.integer :internal_sale_id
      t.integer :payment_product_id
      t.integer :service_provider_id
      t.integer :client_id
      t.string :change
      t.text :cause

      t.timestamps
    end
  end
end
