class CreateServiceProviders < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.references :location
      t.references :user, :null => false
      t.references :company, :null => false

      t.timestamps
    end
  end
end
