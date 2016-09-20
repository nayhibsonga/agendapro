class CreatePromos < ActiveRecord::Migration
  def change
    create_table :promos do |t|
      t.integer :service_id
      t.integer :day_id
      t.integer :morning_discount, default: 0
      t.integer :afternoon_discount, default: 0
      t.integer :night_discount, default: 0

      t.timestamps
    end
  end
end
