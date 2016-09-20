class ChangeSessionsDefault < ActiveRecord::Migration
  def change
  	change_column :services, :sessions_amount, :integer, default: nil
  end
end
