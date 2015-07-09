class ChangeProviderOfNotificationProviders < ActiveRecord::Migration
  def change
    rename_column :notification_providers, :provider_id, :service_provider_id
  end
end
