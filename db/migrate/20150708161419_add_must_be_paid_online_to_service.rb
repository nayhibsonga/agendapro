class AddMustBePaidOnlineToService < ActiveRecord::Migration
  def change
  	add_column :services, :must_be_paid_online, :boolean, default: false
  end
end
