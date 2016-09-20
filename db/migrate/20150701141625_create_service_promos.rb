class CreateServicePromos < ActiveRecord::Migration
  def change
    create_table :service_promos do |t|
      t.integer :service_id

      t.timestamps
    end
  end
end
