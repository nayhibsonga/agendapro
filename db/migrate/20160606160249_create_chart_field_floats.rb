class CreateChartFieldFloats < ActiveRecord::Migration
  def change
    create_table :chart_field_floats do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.float :value

      t.timestamps
    end
  end
end
