class AddFieldsToEmailContent < ActiveRecord::Migration
  def change
    add_column :email_contents, :from, :string
    add_column :email_contents, :to, :text
    add_column :email_contents, :subject, :string
  end
end
