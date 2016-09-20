class CreateCompanyCronLogs < ActiveRecord::Migration
  def change
    create_table :company_cron_logs do |t|
      t.integer :company_id
      t.integer :action_ref
      t.text :details

      t.timestamps
    end
  end
end
