class CreateDowngradeLogs < ActiveRecord::Migration
  def change
    create_table :downgrade_logs do |t|
      t.integer :company_id
      t.integer :plan_id
      t.float :debt

      t.timestamps
    end
  end
end
