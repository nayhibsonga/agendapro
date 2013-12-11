class CreateCompanySettings < ActiveRecord::Migration
  def change
    create_table :company_settings do |t|
      t.text :signature
      t.boolean :email, :default => false
      t.boolean :sms, :default => false
      t.references :company, :null => false

      t.timestamps
    end
  end
end
