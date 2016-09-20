class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
      t.integer :code
      t.string :name

      t.timestamps
    end
  end
end
