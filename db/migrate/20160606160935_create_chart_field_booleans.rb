class CreateChartFieldBooleans < ActiveRecord::Migration
  def change
    create_table :chart_field_booleans do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.boolean :value

      t.timestamps
    end
  end
end
