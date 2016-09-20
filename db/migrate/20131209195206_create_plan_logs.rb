class CreatePlanLogs < ActiveRecord::Migration
  def change
    create_table :plan_logs do |t|
      t.integer :prev_plan_id, :null => false
      t.integer :new_plan_id, :null => false
      t.references :company, :index => true, :null => false

      t.timestamps
    end
  end
end
