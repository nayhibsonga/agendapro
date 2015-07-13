class AddCompanyToProducts < ActiveRecord::Migration
  def change
  	rename_column :products, :company_id_id, :company_id
  	add_reference :product_categories, :company, index: true, foreign_key: true
  end
end
