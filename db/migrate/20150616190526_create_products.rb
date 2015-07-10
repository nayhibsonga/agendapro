class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :company_id, index: true
      t.string :name, default: ''
      t.float :price, default: 0
      t.text :description, defaut:''

      t.timestamps
    end
  end
end
