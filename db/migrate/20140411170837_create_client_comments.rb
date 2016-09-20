class CreateClientComments < ActiveRecord::Migration
  def change
    create_table :client_comments do |t|
      t.references :client, index: true
      t.text :comment

      t.timestamps
    end
  end
end
