class CreateMarketplaceCategories < ActiveRecord::Migration
  def change
    create_table :marketplace_categories do |t|
      t.string :name, default: '', null: false
      t.boolean :show_in_marketplace, default: false

      t.timestamps
    end
  end
end
