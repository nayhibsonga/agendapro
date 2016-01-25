class AddSendingStatusToEmailContent < ActiveRecord::Migration
  def change
    add_column :email_contents, :name, :string
  end
end
