class CreatePlanLogs < ActiveRecord::Migration
  def change
    create_table :plan_logs do |t|
      t.integer :prev_plan_id
      t.integer :new_plan_id
      t.integer :company_id

      t.timestamps
    end
  end
end
