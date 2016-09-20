class AddOnlinePayableToServices < ActiveRecord::Migration
  def change
  	add_column :services, :online_payable, :boolean, default: false
  end
end
