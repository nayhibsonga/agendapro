class CreateEmailBlacklists < ActiveRecord::Migration
  def change
    create_table :email_blacklists do |t|
      t.string :email
      t.string :sender
      t.string :status

      t.timestamps
    end
  end
end
