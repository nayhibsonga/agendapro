class CreateBundles < ActiveRecord::Migration
  def change
    create_table :bundles do |t|
      t.string :name, null: false, default: ''
      t.decimal :price, null: false, default: 0.0
      t.references :service_category, index: true
      t.references :company, index: true
      t.text :description, default: ''

      t.timestamps
    end
  end
end
