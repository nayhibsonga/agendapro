class CreateProductDisplays < ActiveRecord::Migration
  def change
    create_table :product_displays do |t|
      t.string :name
      t.integer :company_id

      t.timestamps
    end
  end
end
