class RemoveLocationFromUser < ActiveRecord::Migration
  def change
  	User.where("users.location_id IS NOT NULL").each do |user|
  		if Location.where(id: user.location_id).count > 0
	  		user.locations = Location.where(id: user.location_id)
	  		user.save
	  	end
  	end
    remove_reference :users, :location, index: true
  end
end
