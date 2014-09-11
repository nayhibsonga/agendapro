class RemoveLocationFromUser < ActiveRecord::Migration
  def change
    remove_reference :users, :location, index: true
  end
end
