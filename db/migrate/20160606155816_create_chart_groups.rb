class CreateChartGroups < ActiveRecord::Migration
  def change
    create_table :chart_groups do |t|
      t.references :company, index: true
      t.string :name
      t.integer :order

      t.timestamps
    end
  end
end
