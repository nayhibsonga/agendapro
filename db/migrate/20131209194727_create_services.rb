class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.float :price
      t.integer :duration
      t.text :description
      t.boolean :group_service
      t.integer :capacity
      t.boolean :waiting_list
      t.integer :company_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
