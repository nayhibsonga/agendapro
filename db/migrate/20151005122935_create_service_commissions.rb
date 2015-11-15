class CreateServiceCommissions < ActiveRecord::Migration
  def change
    create_table :service_commissions do |t|
      t.integer :service_provider_id
      t.integer :service_id
      t.float :amount, default: 0
      t.boolean :is_percent, default: false

      t.timestamps
    end
  end
end
