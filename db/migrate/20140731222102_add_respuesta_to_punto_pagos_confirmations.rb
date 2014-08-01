class AddRespuestaToPuntoPagosConfirmations < ActiveRecord::Migration
  def change
    add_column :punto_pagos_confirmations, :respuesta, :string
  end
end
