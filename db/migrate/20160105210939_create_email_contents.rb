class CreateEmailContents < ActiveRecord::Migration
  def change
    create_table :email_contents do |t|
      t.references :template, index: true
      t.json :data, null: false

      t.timestamps
    end
  end
end
