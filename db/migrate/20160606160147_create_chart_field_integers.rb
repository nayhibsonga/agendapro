class CreateChartFieldIntegers < ActiveRecord::Migration
  def change
    create_table :chart_field_integers do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.integer :value

      t.timestamps
    end
  end
end
