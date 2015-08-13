class CreateUserSearches < ActiveRecord::Migration
  def change
    create_table :user_searches do |t|
      t.references :user, index: true
      t.string :search_text, default: ""

      t.timestamps
    end
  end
end
