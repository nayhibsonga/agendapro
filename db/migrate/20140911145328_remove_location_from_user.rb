class RemoveLocationFromUser < ActiveRecord::Migration
  def change
  	User.where("users.location_id IS NOT NULL").each do |user|
  		user.locations = Location.where(id: user.location_id)
  		user.save
  	end
    remove_reference :users, :location, index: true
  end
end
