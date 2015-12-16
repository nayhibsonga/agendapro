class CreateCompanyPlanSettings < ActiveRecord::Migration
  def change
    create_table :company_plan_settings do |t|
      t.integer :locations
      t.integer :service_providers
      t.integer :monthly_mails
      t.boolean :has_custom_price
      t.float :custom_price

      t.timestamps
    end
  end
end
