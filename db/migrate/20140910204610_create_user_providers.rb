class CreateUserProviders < ActiveRecord::Migration
  def change
    create_table :user_providers do |t|
      t.references :user, index: true
      t.references :service_provider, index: true

      t.timestamps
    end
  end
end
