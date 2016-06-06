class CreateChartFieldDatetimes < ActiveRecord::Migration
  def change
    create_table :chart_field_datetimes do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.datetime :value

      t.timestamps
    end
  end
end
