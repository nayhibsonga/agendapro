class AddSendingMethodToEmailSending < ActiveRecord::Migration
  def up
    add_column :email_sendings, :method, :string
    change_column :email_sendings, :detail, "JSON USING CAST(detail AS JSON)"
  end

  def down
    remove_column :email_sendings, :method, :string
    change_column :email_sendings, :detail, :string
  end
end
