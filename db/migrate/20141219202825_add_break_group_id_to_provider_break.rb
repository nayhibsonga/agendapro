class AddBreakGroupIdToProviderBreak < ActiveRecord::Migration
  def change
    add_column :provider_breaks, :break_group_id, :integer
  end
end
