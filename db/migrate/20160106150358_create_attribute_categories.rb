class CreateAttributeCategories < ActiveRecord::Migration
  def change
    create_table :attribute_categories do |t|
      t.integer :attribute_id
      t.string :category

      t.timestamps
    end
  end
end
