class CreateBooleanAttributes < ActiveRecord::Migration
  def change
    create_table :boolean_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.boolean :value

      t.timestamps
    end
  end
end
