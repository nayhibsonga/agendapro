class AddActiveToStaffCode < ActiveRecord::Migration
  def change
    add_column :staff_codes, :active, :boolean, default: true
  end
end
