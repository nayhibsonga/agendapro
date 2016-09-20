class CreatePuntoPagosConfirmations < ActiveRecord::Migration
  def change
    create_table :punto_pagos_confirmations do |t|
      t.string :token, :null => false
      t.string :trx_id, :null => false
      t.string :payment_method, :null => false
      t.decimal :amount, :null => false
      t.date :approvement_date, :null => false
      t.string :card_number
      t.string :dues_number
      t.string :dues_type
      t.string :dues_amount
      t.date :first_due_date
      t.string :operation_number
      t.string :authorization_code, :null => false

      t.timestamps
    end
  end
end
