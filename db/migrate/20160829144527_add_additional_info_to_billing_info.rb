class AddAdditionalInfoToBillingInfo < ActiveRecord::Migration
  def change
    add_column :billing_infos, :additional_info, :string, default: ""
  end
end
