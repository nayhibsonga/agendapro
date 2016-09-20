class AddTokenToBillingLog < ActiveRecord::Migration
  def change
    add_column :billing_logs, :token, :string
    add_column :billing_logs, :trx_id, :string
  end
end
