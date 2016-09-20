class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.references :company, index: true, null: false
      t.references :location, index: true, null: false
      t.references :service, index: true, null: false
      t.references :service_provider, index: true, null: false
      t.references :client, index: true, null: false
      t.references :user, index: true, null: false
      t.float :quality, null: false
      t.float :style, null: false
      t.float :price, null: false
      t.float :overall, null: false
      t.text :comments, default: "", null: false

      t.timestamps
    end
  end
end
