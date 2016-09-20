class AddSessionsToService < ActiveRecord::Migration
  def change
  	add_column :services, :has_sessions, :boolean, default: false
  	add_column :services, :sessions_amount, :integer, default: 0
  end
end
