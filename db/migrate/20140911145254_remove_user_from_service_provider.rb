class RemoveUserFromServiceProvider < ActiveRecord::Migration
  def change
    remove_reference :service_providers, :user, index: true
  end
end
