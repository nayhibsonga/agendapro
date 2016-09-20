class CreateCompanyFromEmails < ActiveRecord::Migration
  def change
    create_table :company_from_emails do |t|
      t.string :email, null: false
      t.references :company, index: true

      t.timestamps
    end
  end
end
