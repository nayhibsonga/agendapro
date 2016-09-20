class AddConfirmedToCompanyFromEmail < ActiveRecord::Migration
  def change
    add_column :company_from_emails, :confirmed, :boolean, default: false
  end
end
