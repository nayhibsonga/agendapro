class CreateCustomFilters < ActiveRecord::Migration
  def change
    create_table :custom_filters do |t|
      t.integer :company_id
      t.string :name

      t.timestamps
    end
  end
end
