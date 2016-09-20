class AddReceiveOffersToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :receives_offers, :boolean, default: true
  end
end
