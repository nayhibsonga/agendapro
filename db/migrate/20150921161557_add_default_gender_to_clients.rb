class AddDefaultGenderToClients < ActiveRecord::Migration
  def change
  	change_column :clients, :gender, :integer, default: 0
  end
end
