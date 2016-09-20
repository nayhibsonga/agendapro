class CreatePettyCashes < ActiveRecord::Migration
  def change
    create_table :petty_cashes do |t|
      t.integer :location_id
      t.float :cash, default: 0.0

      t.timestamps
    end
  end
end
