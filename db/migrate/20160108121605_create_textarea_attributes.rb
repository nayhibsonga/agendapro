class CreateTextareaAttributes < ActiveRecord::Migration
  def change
    create_table :textarea_attributes do |t|
      t.integer :attribute_id
      t.integer :client_id
      t.text :value

      t.timestamps
    end
  end
end
