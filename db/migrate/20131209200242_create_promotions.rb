class CreatePromotions < ActiveRecord::Migration
  def change
    create_table :promotions do |t|
      t.string :code, :null => false
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
