class CreateNumericCustomFilters < ActiveRecord::Migration
  def change
    create_table :numeric_custom_filters do |t|
      t.integer :custom_filter_id
      t.integer :attribute_id
      t.float :value1
      t.float :value2
      t.string :option

      t.timestamps
    end
  end
end
