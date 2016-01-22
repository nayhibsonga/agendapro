class CreateCompanyPlanSettings < ActiveRecord::Migration
  def change
    create_table :company_plan_settings do |t|
      t.integer :company_id
      t.integer :locations, default: 1
      t.integer :service_providers, default: 1
      t.integer :monthly_mails, default: 0
      t.boolean :has_custom_price, default: false
      t.float :custom_price

      t.timestamps
    end
  end
end
