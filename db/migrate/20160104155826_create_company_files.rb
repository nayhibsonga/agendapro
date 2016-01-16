class CreateCompanyFiles < ActiveRecord::Migration
  def change
    create_table :company_files do |t|
      t.integer :company_id
      t.text :name
      t.text :full_path
      t.text :public_url

      t.timestamps
    end
  end
end
