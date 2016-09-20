class AddPromotionsToService < ActiveRecord::Migration
  def change
  	add_column :services, :has_time_discount, :boolean, default: false
  	add_column :services, :has_last_minute_discount, :boolean, default: false
  	add_column :services, :last_minute_hours, :integer, default: 0
  	add_column :services, :last_minute_discount, :integer, default: 0
  end
end
