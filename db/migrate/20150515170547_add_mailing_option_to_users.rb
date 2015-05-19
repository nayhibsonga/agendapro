class AddMailingOptionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mailing_option, :boolean, default: true
  end
end
