class AddActiveToPromoTimes < ActiveRecord::Migration
  def change
  	add_column :promo_times, :active, :boolean, default: false
  end
end
