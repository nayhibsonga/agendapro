class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name, :null => false
      t.integer :locations, :null => false
      t.integer :service_providers, :null => false
      t.boolean :custom, :default => false

      t.timestamps
    end
  end
end
