class CreatePromoTimes < ActiveRecord::Migration
  def change
    create_table :promo_times do |t|
      t.integer :company_setting_id
      t.datetime :morning_start, :null => false
      t.datetime :morning_end, :null => false
      t.datetime :afternoon_start, :null => false
      t.datetime :afternoon_end, :null => false
      t.datetime :night_start, :null => false
      t.datetime :night_end, :null => false
      t.float :morning_default, default: 0
      t.float :afternoon_default, default: 0
      t.float :night_default, default: 0

      t.timestamps
    end
  end
end
