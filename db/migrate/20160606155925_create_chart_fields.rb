class CreateChartFields < ActiveRecord::Migration
  def change
    create_table :chart_fields do |t|
      t.references :company, index: true
      t.references :chart_group, index: true
      t.string :name
      t.text :description
      t.string :datatype
      t.string :slug
      t.boolean :mandatory
      t.integer :order

      t.timestamps
    end
  end
end
