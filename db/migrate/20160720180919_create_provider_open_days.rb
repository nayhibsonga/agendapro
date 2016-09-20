class CreateProviderOpenDays < ActiveRecord::Migration
  def change
    create_table :provider_open_days do |t|
      t.references :service_provider, index: true
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end
end
