class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.references :company, index: true
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :address
      t.string :district
      t.string :city
      t.integer :age
      t.integer :gender
      t.date :birth_date

      t.timestamps
    end
  end
end
