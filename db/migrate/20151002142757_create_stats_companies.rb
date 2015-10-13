class CreateStatsCompanies < ActiveRecord::Migration
  def change
    create_table :stats_companies do |t|
      t.references :company, index: true, null: false
      t.string :company_name, default: "", null: false
      t.datetime :company_start, null: false
      t.datetime :last_booking, null: false
      t.integer :week_bookings, defaul: 0, null: false
      t.integer :past_week_bookings, defaul: 0, null: false
      t.float :web_bookings, defaul: 0.0, null: false

      t.timestamps
    end
  end
end
