class DeleteOldNotification < ActiveRecord::Migration
  def change
    remove_column :service_providers, :notification_email
    remove_column :service_providers, :booking_configuration_email
    remove_column :locations, :notification
    remove_column :locations, :booking_configuration_email
    remove_column :company_settings, :booking_configuration_email
  end
end
