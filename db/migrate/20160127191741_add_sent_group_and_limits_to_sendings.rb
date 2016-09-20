class AddSentGroupAndLimitsToSendings < ActiveRecord::Migration
  def change
    add_column :email_sendings, :total_sendings, :integer, default: 0
    add_column :email_sendings, :total_recipients, :integer, default: 0
    add_column :email_sendings, :detail, :string
  end
end
