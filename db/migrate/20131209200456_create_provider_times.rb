class CreateProviderTimes < ActiveRecord::Migration
  def change
    create_table :provider_times do |t|
      t.time :open, :null => false
      t.time :close, :null => false
      t.references :service_provider, :null => false
      t.references :day, :null => false

      t.timestamps
    end
  end
end
	