class CreateCashiers < ActiveRecord::Migration
  def change
    create_table :cashiers do |t|
      t.integer :company_id
      t.string :name
      t.string :code
      t.boolean :active

      t.timestamps
    end
  end
end
