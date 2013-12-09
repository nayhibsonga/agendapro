class CreateCompanySettings < ActiveRecord::Migration
  def change
    create_table :company_settings do |t|
      t.text :signature
      t.boolean :email
      t.boolean :sms
      t.integer :company_id

      t.timestamps
    end
  end
end
