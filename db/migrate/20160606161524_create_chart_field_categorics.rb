class CreateChartFieldCategorics < ActiveRecord::Migration
  def change
    create_table :chart_field_categorics do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.references :chart_category, index: true

      t.timestamps
    end
  end
end
