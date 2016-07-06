class CreateEmployeeCodes < ActiveRecord::Migration
  def change
    create_table :employee_codes do |t|
      t.string :name
      t.string :code
      t.references :company, index: true
      t.boolean :active
      t.boolean :staff
      t.boolean :cashier

      t.timestamps
    end
  end
end
