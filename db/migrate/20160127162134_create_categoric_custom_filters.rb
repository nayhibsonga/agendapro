class CreateCategoricCustomFilters < ActiveRecord::Migration
  def change
    create_table :categoric_custom_filters do |t|
      t.integer :custom_filter_id
      t.integer :attribute_id
      t.string :categories_ids

      t.timestamps
    end
  end
end
