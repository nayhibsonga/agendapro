class CreateEconomicSectors < ActiveRecord::Migration
  def change
    create_table :economic_sectors do |t|
      t.string :name, :null => false

      t.timestamps
    end
  end
end
