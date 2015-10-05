class AddLocationToProviderGroup < ActiveRecord::Migration
  def change
    add_reference :provider_groups, :location, index: true
  end
end
