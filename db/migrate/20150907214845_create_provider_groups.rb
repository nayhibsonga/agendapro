class CreateProviderGroups < ActiveRecord::Migration
  def change
    create_table :provider_groups do |t|
      t.references :company, index: true
      t.string :name, null: false, default: ""
      t.integer :order, null: false, default: 0

      t.timestamps
    end
  end
end
