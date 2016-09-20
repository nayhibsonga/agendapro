class AddWeeksToProviderBreakRepeats < ActiveRecord::Migration
  def change
  	add_column :provider_break_repeats, :weeks, :integer, default: 0
  end
end
