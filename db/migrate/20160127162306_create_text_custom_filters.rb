class CreateTextCustomFilters < ActiveRecord::Migration
  def change
    create_table :text_custom_filters do |t|
      t.integer :custom_filter_id
      t.integer :attribute_id
      t.text :text

      t.timestamps
    end
  end
end
