class CreateFloatAttributes < ActiveRecord::Migration
  def change
    create_table :float_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.float :value

      t.timestamps
    end
  end
end
