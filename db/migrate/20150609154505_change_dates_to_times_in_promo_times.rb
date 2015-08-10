class ChangeDatesToTimesInPromoTimes < ActiveRecord::Migration
  def change
  	change_column :promo_times, :morning_start, :time, :null => false, default: "2000-01-01 09:00:00"
  	change_column :promo_times, :morning_end, :time, :null => false, default: "2000-01-01 12:00:00"
  	change_column :promo_times, :afternoon_start, :time, :null => false, default: "2000-01-01 12:00:00"
  	change_column :promo_times, :afternoon_end, :time, :null => false, default: "2000-01-01 18:00:00"
  	change_column :promo_times, :night_start, :time, :null => false, default: "2000-01-01 18:00:00"
  	change_column :promo_times, :night_end, :time, :null => false, default: "2000-01-01 20:00:00"
  end
end
