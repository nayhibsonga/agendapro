class CreateBillingInfos < ActiveRecord::Migration
  def change
    create_table :billing_infos do |t|
      t.string :name
      t.string :rut
      t.string :address
      t.string :sector
      t.string :email
      t.string :phone
      t.references :company, index: true

      t.timestamps
    end
  end
end
