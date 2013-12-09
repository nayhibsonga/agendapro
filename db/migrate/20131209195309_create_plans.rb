class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.integer :locations
      t.integer :staffs
      t.boolean :custom

      t.timestamps
    end
  end
end
