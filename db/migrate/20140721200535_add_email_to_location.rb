class AddEmailToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :email, :string, default: ''
    add_column :locations, :notification, :boolean, default: false
  end
end
