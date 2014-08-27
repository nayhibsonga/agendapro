class RemoveNextPaymentFromBillingLogs < ActiveRecord::Migration
  def change
    remove_column :billing_logs, :next_payment, :date
  end
end
