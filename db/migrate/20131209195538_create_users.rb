  class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      #t.string :email, :null => false
      t.string :phone
      #t.string :user_name
      #t.string :password
      t.references :role, :index => true, :null => false
      t.references :company, :index => true

      t.timestamps
    end
  end
end
