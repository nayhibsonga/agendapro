class CreateDateTimeAttributes < ActiveRecord::Migration
  def change
    create_table :date_time_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.datetime :value

      t.timestamps
    end
  end
end
