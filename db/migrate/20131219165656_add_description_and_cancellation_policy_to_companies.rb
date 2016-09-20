class AddDescriptionAndCancellationPolicyToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :description, :text
    add_column :companies, :cancellation_policy, :text
  end
end
