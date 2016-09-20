class AddCompanyIdToPaymentAccount < ActiveRecord::Migration
  def change
  	add_column :payment_accounts, :company_id, :integer
  end
end
