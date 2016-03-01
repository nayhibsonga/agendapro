class CreateBooleanCustomFilters < ActiveRecord::Migration
  def change
    create_table :boolean_custom_filters do |t|
      t.integer :custom_filter_id
      t.integer :attribute_id
      t.boolean :option

      t.timestamps
    end
  end
end
