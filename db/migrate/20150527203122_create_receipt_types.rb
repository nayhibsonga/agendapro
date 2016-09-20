class CreateReceiptTypes < ActiveRecord::Migration
  def change
    create_table :receipt_types do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
