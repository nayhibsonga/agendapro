class AddProviderBreakRepeat < ActiveRecord::Migration
  def change
  	add_column :provider_breaks, :break_repeat_id, :integer
  end
end
