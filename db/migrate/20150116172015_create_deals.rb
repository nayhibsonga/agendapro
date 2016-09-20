class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string :code, null: false
      t.integer :quantity, null: false
      t.boolean :active, default: true
      t.integer :constraint_option, null: false
      t.integer :constraint_quantity, null:false
      t.references :company_id, index: true

      t.timestamps
    end
  end
end
