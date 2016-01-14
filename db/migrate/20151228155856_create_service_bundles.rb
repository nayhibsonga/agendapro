class CreateServiceBundles < ActiveRecord::Migration
  def change
    create_table :service_bundles do |t|
      t.references :service, index: true
      t.references :bundle, index: true
      t.integer :order, null: false, default: 0
      t.decimal :price, null: false, default: 0.0

      t.timestamps
    end
  end
end
