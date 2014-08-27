class ChangeResponseToPuntoPagosConfirmations < ActiveRecord::Migration
  def change
  	rename_column :punto_pagos_confirmations, :respuesta, :response
  	change_column :punto_pagos_confirmations, :amount, :float
  end
end
