class AddMobileTokerToUsers < ActiveRecord::Migration
  def change
    add_column :users, :mobile_token, :string
  end
end
