class CreateChartFieldFiles < ActiveRecord::Migration
  def change
    create_table :chart_field_files do |t|
      t.references :chart_field, index: true
      t.references :client, index: true
      t.references :client_file, index: true

      t.timestamps
    end
  end
end
