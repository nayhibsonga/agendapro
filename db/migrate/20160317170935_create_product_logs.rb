class CreateProductLogs < ActiveRecord::Migration
  def change
    create_table :product_logs do |t|
      t.references :product, index: true
      t.references :internal_sale, index: true
      t.references :payment_product, index: true
      t.references :service_provider, index: true
      t.references :client, index: true
      t.string :change
      t.text :cause

      t.timestamps
    end
  end
end
