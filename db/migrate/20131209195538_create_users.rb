  class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      #t.string :email, :null => false
      t.string :phone, :null => false
      #t.string :user_name
      #t.string :password
      t.references :role, :index => true, :null => false
      t.references :company, :index => true

      t.timestamps
    end
  end
end
