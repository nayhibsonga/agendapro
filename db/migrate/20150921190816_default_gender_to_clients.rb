class DefaultGenderToClients < ActiveRecord::Migration
  def change
  	change_column :clients, :gender, :integer, default: 0, null: true
  end
end
