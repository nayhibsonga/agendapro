class CreateServiceStaffs < ActiveRecord::Migration
  def change
    create_table :service_staffs do |t|
      t.references :service, :null => false
      t.references :staff, :null => false

      t.timestamps
    end
  end
end
