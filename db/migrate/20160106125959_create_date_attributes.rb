class CreateDateAttributes < ActiveRecord::Migration
  def change
    create_table :date_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.date :value

      t.timestamps
    end
  end
end
