class DeleteMailingOptionFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :mailing_option
  end
end
