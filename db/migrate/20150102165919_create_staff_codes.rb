class CreateStaffCodes < ActiveRecord::Migration
  def change
    create_table :staff_codes do |t|
      t.string :staff
      t.string :code
      t.references :company, index: true

      t.timestamps
    end
  end
end
