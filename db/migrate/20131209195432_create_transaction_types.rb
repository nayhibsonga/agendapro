class CreateTransactionTypes < ActiveRecord::Migration
  def change
    create_table :transaction_types do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
