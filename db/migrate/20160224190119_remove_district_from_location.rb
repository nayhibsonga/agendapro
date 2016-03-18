class RemoveDistrictFromLocation < ActiveRecord::Migration
  def change
    remove_reference :locations, :district, index: true
  end
end
