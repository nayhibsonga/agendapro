class AddFacebookPageIdToCompanySettings < ActiveRecord::Migration
  def change
    add_column :company_settings, :page_id, :string
  end
end
