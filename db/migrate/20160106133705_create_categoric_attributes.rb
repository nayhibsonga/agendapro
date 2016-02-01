class CreateCategoricAttributes < ActiveRecord::Migration
  def change
    create_table :categoric_attributes do |t|
      t.integer :client_id
      t.integer :attribute_id
      t.integer :attribute_category_id

      t.timestamps
    end
  end
end
