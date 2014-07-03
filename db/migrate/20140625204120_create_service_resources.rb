class CreateServiceResources < ActiveRecord::Migration
  def change
    create_table :service_resources do |t|
      t.references :service, index: true
      t.references :resource, index: true

      t.timestamps
    end
  end
end
