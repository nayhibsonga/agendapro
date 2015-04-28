class CreateNotificationEmails < ActiveRecord::Migration
  def change
    create_table :notification_emails do |t|
      t.references :company, index: true
      t.string :email, null: false
      t.integer :receptor_type, default: 0
      t.boolean :summary, default: true
      t.boolean :new, default: false
      t.boolean :modified, default: false
      t.boolean :condifrmed, default: false
      t.boolean :canceled, default: false
      t.boolean :new_web, default: false
      t.boolean :modified_web, default: false
      t.boolean :condifrmed_web, default: false
      t.boolean :canceled_web, default: false

      t.timestamps
    end
  end
end
