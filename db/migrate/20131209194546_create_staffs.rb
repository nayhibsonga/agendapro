class CreateStaffs < ActiveRecord::Migration
  def change
    create_table :staffs do |t|
      t.references :location
      t.references :user, :null => false

      t.timestamps
    end
  end
end
