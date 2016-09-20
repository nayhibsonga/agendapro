class ChangeNullPuntoPagosConfirmations < ActiveRecord::Migration
  def change
  	change_column :punto_pagos_confirmations, :token, :string, :null => true
  	change_column :punto_pagos_confirmations, :trx_id, :string, :null => true
  	change_column :punto_pagos_confirmations, :payment_method, :string, :null => true
  	change_column :punto_pagos_confirmations, :amount, :float, :null => true
  	change_column :punto_pagos_confirmations, :approvement_date, :date, :null => true
  	change_column :punto_pagos_confirmations, :authorization_code, :string, :null => true
  end
end