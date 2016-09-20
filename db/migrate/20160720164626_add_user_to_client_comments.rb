class AddUserToClientComments < ActiveRecord::Migration
  def change
  	add_reference :client_comments, :user, index: true
  	add_reference :client_comments, :last_modifier, references: :users, index: true
  end
end
