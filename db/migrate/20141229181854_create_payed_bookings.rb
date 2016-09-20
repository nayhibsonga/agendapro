class CreatePayedBookings < ActiveRecord::Migration
  def change
    create_table :payed_bookings do |t|
      t.integer :booking_id
      t.integer :punto_pagos_confirmation_id

      t.timestamps
    end
  end
end
