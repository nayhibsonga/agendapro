class SeparateLastMinuteDiscount < ActiveRecord::Migration
  def change
  	remove_column :services, :last_minute_discount, :integer
  	remove_column :services, :last_minute_hours, :integer
  end
end
