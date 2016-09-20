class AddOutcallToServices < ActiveRecord::Migration
  def change
    add_column :services, :outcall, :boolean, default: false
  end
end
