class AddActiveFieldToEmailContents < ActiveRecord::Migration
  def change
    add_column :email_contents, :active, :boolean, default: true
    add_column :email_contents, :deactivation_date, :datetime
  end
end
