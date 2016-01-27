class CreateDateCustomFilters < ActiveRecord::Migration
  def change
    create_table :date_custom_filters do |t|
      t.integer :custom_filter_id
      t.integer :attribute_id
      t.datetime :date1
      t.datetime :date2
      t.string :option

      t.timestamps
    end
  end
end
