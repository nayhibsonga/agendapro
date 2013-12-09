class CreateServiceStaffs < ActiveRecord::Migration
  def change
    create_table :service_staffs do |t|
      t.integer :service_id
      t.integer :staff_id

      t.timestamps
    end
  end
end
