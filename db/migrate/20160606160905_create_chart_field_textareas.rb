class CreateChartFieldTextareas < ActiveRecord::Migration
  def change
    create_table :chart_field_textareas do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.text :value

      t.timestamps
    end
  end
end
