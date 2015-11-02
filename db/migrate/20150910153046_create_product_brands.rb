class CreateProductBrands < ActiveRecord::Migration
  def change
    create_table :product_brands do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
  end
end
