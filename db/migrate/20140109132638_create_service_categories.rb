class CreateServiceCategories < ActiveRecord::Migration
  def change
    create_table :service_categories do |t|
      t.string :name, :null => false
      t.references :company, index: true

      t.timestamps
    end
  end
end
