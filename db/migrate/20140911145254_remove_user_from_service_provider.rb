class RemoveUserFromServiceProvider < ActiveRecord::Migration
  def change
  	ServiceProvider.where("service_providers.user_id IS NOT NULL").each do |service_provider|
  		user = User.find(service_provider.user_id)
  		user.service_providers = [service_provider]
  		user.save
  	end
    remove_reference :service_providers, :user, index: true
  end
end
