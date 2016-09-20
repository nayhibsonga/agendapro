class CreatePuntoPagosCreations < ActiveRecord::Migration
  def change
    create_table :punto_pagos_creations do |t|
      t.string :trx_id, :null => false
      t.string :payment_method, :null => false
      t.decimal :amount, :null => false
      t.text :details

      t.timestamps
    end
  end
end
