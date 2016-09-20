class CreateServiceProviders < ActiveRecord::Migration
  def change
    create_table :service_providers do |t|
      t.references :location, :index => true
      t.references :user, :index => true
      t.references :company, :index => true, :null => false
      t.string :notification_email
      t.string :public_name

      t.timestamps
    end
  end
end
