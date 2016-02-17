class CreateAttributeGroups < ActiveRecord::Migration
  def change
    create_table :attribute_groups do |t|
      t.integer :company_id
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
