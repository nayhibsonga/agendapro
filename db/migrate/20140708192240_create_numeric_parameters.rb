class CreateNumericParameters < ActiveRecord::Migration
  def change
    create_table :numeric_parameters do |t|
      t.string :name
      t.float :value

      t.timestamps
    end
  end
end
