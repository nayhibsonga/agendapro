class ChangePuntoPagosAmount < ActiveRecord::Migration
  def change
  	change_column :punto_pagos_creations, :amount,  :float
  end
end
