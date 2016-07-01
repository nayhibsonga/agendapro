class CreateChartFieldDates < ActiveRecord::Migration
  def change
    create_table :chart_field_dates do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.date :value

      t.timestamps
    end
  end
end
