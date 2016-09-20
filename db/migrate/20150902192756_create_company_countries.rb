class CreateCompanyCountries < ActiveRecord::Migration
  def change
    create_table :company_countries do |t|
      t.references :company, index: true
      t.references :country, index: true
      t.string :web_address, default: ""

      t.timestamps
    end
  end
end
