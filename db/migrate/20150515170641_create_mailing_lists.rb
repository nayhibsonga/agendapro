class CreateMailingLists < ActiveRecord::Migration
  def change
    create_table :mailing_lists do |t|
      t.string :first_name, default: ""
      t.string :last_name, default: ""
      t.string :email, default: ""
      t.string :phone, default: ""
      t.boolean :mailing_option, default: true

      t.timestamps
    end
  end
end
