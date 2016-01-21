class AddTimeRestrictedToServices < ActiveRecord::Migration
  def change
    add_column :services, :time_restricted, :boolean, default: false
  end
end
