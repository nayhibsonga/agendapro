class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name, :null => false
      t.float :price
      t.integer :duration, :null => false
      t.text :description
      t.boolean :group_service, :default => false
      t.integer :capacity
      t.boolean :waiting_list, :default => false
      t.references :company, :index => true, :null => false
      t.references :tag, :index => true
      t.references :service_category, :index => true

      t.timestamps
    end
  end
end
