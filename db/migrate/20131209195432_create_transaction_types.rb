class CreateTransactionTypes < ActiveRecord::Migration
  def change
    create_table :transaction_types do |t|
      t.string :name, :null => false
      t.text :description, :null => false

      t.timestamps
    end
  end
end
