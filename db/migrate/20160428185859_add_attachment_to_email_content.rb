class AddAttachmentToEmailContent < ActiveRecord::Migration
  def change
    add_column :email_contents, :attachment_content, :text
    add_column :email_contents, :attachment_type, :string
    add_column :email_contents, :attachment_name, :string
  end
end
