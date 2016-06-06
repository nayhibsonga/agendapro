class CreateChartCategories < ActiveRecord::Migration
  def change
    create_table :chart_categories do |t|
      t.references :chart_field, index: true
      t.string :name

      t.timestamps
    end
  end
end
