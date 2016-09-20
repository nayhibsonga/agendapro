class AddActiveToServices < ActiveRecord::Migration
  def change
    add_column :services, :active, :boolean, :default => true
  end
end
