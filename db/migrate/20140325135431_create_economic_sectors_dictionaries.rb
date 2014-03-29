class CreateEconomicSectorsDictionaries < ActiveRecord::Migration
  def change
    create_table :economic_sectors_dictionaries do |t|
      t.string :name
      t.references :economic_sector, index: true, null: false

      t.timestamps
    end
  end
end
