class CreateServiceStaffs < ActiveRecord::Migration
  def change
    create_table :service_staffs do |t|
      t.references :service, :index => true, :null => false
      t.references :service_provider, :index => true, :null => false

      t.timestamps
    end
  end
end
