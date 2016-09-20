class AddContactToBillingInfo < ActiveRecord::Migration
  def change
    add_column :billing_infos, :contact, :string
  end
end
