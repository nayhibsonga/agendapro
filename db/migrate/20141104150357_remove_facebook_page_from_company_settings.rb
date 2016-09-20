class RemoveFacebookPageFromCompanySettings < ActiveRecord::Migration
  def change
  	remove_column :company_settings, :page_id, :string
  end
end
