class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.integer :quality
      t.integer :style
      t.integer :satifaction
      t.text :comment
      t.references :client, index: true

      t.timestamps
    end
  end
end
