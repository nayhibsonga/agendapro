class CreateCompanyPaymentMethods < ActiveRecord::Migration
  def change
    create_table :company_payment_methods do |t|
      t.string :name, null: false
      t.references :company, null: false, index: true

      t.timestamps
    end
  end
end
