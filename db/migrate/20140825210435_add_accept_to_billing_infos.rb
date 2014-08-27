class AddAcceptToBillingInfos < ActiveRecord::Migration
  def change
    add_column :billing_infos, :accept, :boolean, default: false
  end
end
