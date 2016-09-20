class FixCompanyToDeals < ActiveRecord::Migration
  def change
  	rename_column :deals, :company_id_id, :company_id
  end
end
