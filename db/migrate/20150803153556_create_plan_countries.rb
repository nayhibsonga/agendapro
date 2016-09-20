class CreatePlanCountries < ActiveRecord::Migration
  def change
    create_table :plan_countries do |t|
      t.references :plan, index: true
      t.references :country, index: true
      t.float :price

      t.timestamps
    end
  end
end
