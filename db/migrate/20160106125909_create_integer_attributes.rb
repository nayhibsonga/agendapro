class CreateIntegerAttributes < ActiveRecord::Migration
  def change
    create_table :integer_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.integer :value

      t.timestamps
    end
  end
end
