class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.integer :company_id
      t.string :name
      t.text :description
      t.string :datatype
      t.boolean :mandatory

      t.timestamps
    end
  end
end
