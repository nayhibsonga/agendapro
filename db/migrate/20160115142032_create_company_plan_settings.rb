class CreateCompanyPlanSettings < ActiveRecord::Migration
  def change
    create_table :company_plan_settings do |t|
      t.integer :company_id
      t.float :base_price
      t.float :locations_multiplier

      t.timestamps
    end
  end
end
