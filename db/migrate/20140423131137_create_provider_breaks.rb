class CreateProviderBreaks < ActiveRecord::Migration
  def change
    create_table :provider_breaks do |t|
      t.datetime :start
      t.datetime :end
      t.references :service_provider, index: true

      t.timestamps
    end
  end
end
