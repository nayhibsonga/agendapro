class AddTotalTargetsToEmailSendings < ActiveRecord::Migration
  def change
    add_column :email_sendings, :total_targets, :integer
  end
end
