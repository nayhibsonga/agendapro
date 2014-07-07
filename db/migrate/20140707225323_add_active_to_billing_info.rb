class AddActiveToBillingInfo < ActiveRecord::Migration
  def change
    add_column :billing_infos, :active, :boolean, default: false
  end
end
