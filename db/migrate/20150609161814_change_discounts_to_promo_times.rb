class ChangeDiscountsToPromoTimes < ActiveRecord::Migration
  def change
  	change_column :promo_times, :morning_default, :integer, default: 0
  	change_column :promo_times, :afternoon_default, :integer, default: 0
  	change_column :promo_times, :night_default, :integer, default: 0
  end
end
