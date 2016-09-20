class CreatePayUCreations < ActiveRecord::Migration
  def change
    create_table :pay_u_creations do |t|
      t.string :trx_id, :null => false
      t.string :payment_method, :null => false
      t.float :amount, :null => false
      t.text :details

      t.timestamps
    end
  end
end
